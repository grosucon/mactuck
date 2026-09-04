import AppKit
import MacTuckCore

@MainActor
final class FoldController {
    var dropdownActions: (@MainActor (DisplayOwner) -> DropdownActions)?

    private let reader: any MenuBarReading
    private let windows: any MenuBarWindowReading
    private let ownerReader: any DisplayOwnerReading
    private let settings: AppSettings
    private let exclusions: Exclusions
    private let menuBuilder = ProxyMenuBuilder()
    private var panels: [UInt32: CoverPanel] = [:]
    private var itemsByDisplay: [UInt32: [MenuBarItemRef]] = [:]
    private var ownersByDisplay: [UInt32: DisplayOwner] = [:]
    private var coverState = DisplayCoverState()
    private var covered: Set<UInt32> = []
    private var timer: Timer?
    private var lastRegularApp: NSRunningApplication?

    init(
        reader: any MenuBarReading,
        windows: any MenuBarWindowReading,
        ownerReader: any DisplayOwnerReading,
        settings: AppSettings,
        exclusions: Exclusions
    ) {
        self.reader = reader
        self.windows = windows
        self.ownerReader = ownerReader
        self.settings = settings
        self.exclusions = exclusions
    }

    private var fallbackOwner: DisplayOwner? {
        guard let app = NSWorkspace.shared.menuBarOwningApplication ?? lastRegularApp else { return nil }
        return DisplayOwner(
            pid: app.processIdentifier,
            name: app.localizedName ?? "App",
            bundleID: app.bundleIdentifier
        )
    }

    private var menuBarAutoHides: Bool {
        UserDefaults.standard.persistentDomain(forName: UserDefaults.globalDomain)?["_HIHideMenuBar"] as? Bool ?? false
    }

    func start() {
        let center = NSWorkspace.shared.notificationCenter
        center.addObserver(forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: .main) { [weak self] note in
            let pid = (note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication)?.processIdentifier
            MainActor.assumeIsolated { self?.appActivated(pid: pid) }
        }
        for name in [NSWorkspace.didTerminateApplicationNotification, NSWorkspace.activeSpaceDidChangeNotification] {
            center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                MainActor.assumeIsolated { self?.scheduleRefresh() }
            }
        }
        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.scheduleRefresh() }
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.refresh() }
        }
        refresh()
    }

    func scheduleRefresh() {
        for delay in [0.1, 0.5] {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                MainActor.assumeIsolated { self?.refresh() }
            }
        }
    }

    func refresh() {
        let displays = NSScreen.screens
        guard !menuBarAutoHides, let primary = displays.first(where: { $0.frame.origin == .zero }) else {
            hideAll()
            return
        }
        let screens = displays.compactMap(ScreenInfo.init(screen:))
        let bars = MenuBarWindows.settledBars(
            candidates: windows.barCandidates(),
            screens: screens,
            primaryScreen: primary.frame
        )
        let owners = ownerReader.owners(for: screens, primaryScreen: primary.frame)

        var menuBars: [DisplayMenuBar] = []
        var items: [UInt32: [MenuBarItemRef]] = [:]
        var resolved: [UInt32: DisplayOwner] = [:]
        var suppressed: Set<UInt32> = []

        for bar in bars {
            guard let owner = owners[bar.displayID] ?? fallbackOwner else { continue }
            if let bundleID = owner.bundleID, exclusions.contains(bundleID) {
                suppressed.insert(bar.displayID)
                continue
            }
            if reader.isFullScreen(pid: owner.pid) {
                suppressed.insert(bar.displayID)
                continue
            }
            guard let snapshot = reader.snapshot(pid: owner.pid) else { continue }
            menuBars.append(DisplayMenuBar(displayID: bar.displayID, barFrame: bar.barFrame, layout: snapshot.layout))
            items[bar.displayID] = Array(snapshot.items.dropFirst())
            resolved[bar.displayID] = owner
        }
        itemsByDisplay = items
        ownersByDisplay = resolved

        let placements = CoverGeometry.placements(for: menuBars, primaryScreen: primary.frame)
        let placed = Set(placements.map(\.displayID))
        let update = coverState.update(
            covered: placed.union(suppressed),
            liveDisplays: Set(screens.map(\.displayID)),
            panelDisplays: Set(panels.keys)
        )

        for placement in placements {
            guard let owner = resolved[placement.displayID] else { continue }
            show(placement, appName: owner.name)
        }
        for displayID in suppressed {
            panels[displayID]?.orderOut(nil)
        }
        for displayID in update.hide {
            panels[displayID]?.orderOut(nil)
        }
        for displayID in update.drop {
            panels[displayID]?.orderOut(nil)
            panels[displayID] = nil
        }
        report(covered: placed)
    }

    func showDropdown(from panel: CoverPanel) {
        guard let dropdownActions, let owner = ownersByDisplay[panel.displayID] else { return }
        let menu = menuBuilder.menu(items: itemsByDisplay[panel.displayID] ?? [], actions: dropdownActions(owner))
        let anchor = NSPoint(x: panel.frame.minX + panel.cover.pillMinX, y: panel.frame.minY - 12)
        menu.popUp(positioning: nil, at: anchor, in: nil)
    }

    func exclude(bundleID: String) {
        exclusions.add(bundleID)
        Log.cover.notice("excluded \(bundleID, privacy: .public)")
        refresh()
    }

    private func show(_ placement: CoverPlacement, appName: String) {
        let panel = panels[placement.displayID] ?? makePanel(for: placement.displayID)
        var frame = placement.frame
        panel.setFrame(frame, display: false)
        panel.cover.material = settings.material
        panel.cover.configure(appName: appName, pillX: placement.pillX)
        frame.size.width = max(frame.width, panel.cover.pillMaxX + CoverGeometry.padding)
        panel.setFrame(frame, display: true)
        panel.orderFrontRegardless()
        Log.cover.debug("display=\(placement.displayID) x=\(placement.frame.minX) width=\(placement.frame.width) height=\(placement.frame.height)")
    }

    private func makePanel(for displayID: UInt32) -> CoverPanel {
        let panel = CoverPanel(displayID: displayID)
        panel.cover.onClick = { [weak self, weak panel] in
            guard let panel else { return }
            self?.showDropdown(from: panel)
        }
        panels[displayID] = panel
        return panel
    }

    private func report(covered newValue: Set<UInt32>) {
        guard newValue != covered else { return }
        covered = newValue
        let ids = newValue.sorted().map(String.init).joined(separator: ",")
        Log.cover.notice("covering displays=[\(ids, privacy: .public)]")
    }

    private func appActivated(pid: pid_t?) {
        if let pid, let app = NSRunningApplication(processIdentifier: pid), app.activationPolicy == .regular {
            lastRegularApp = app
        }
        scheduleRefresh()
    }

    private func hideAll() {
        coverState.reset()
        report(covered: [])
        for panel in panels.values {
            panel.orderOut(nil)
        }
    }
}

private extension ScreenInfo {
    init?(screen: NSScreen) {
        guard let number = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber else { return nil }
        self.init(displayID: number.uint32Value, frame: screen.frame)
    }
}
