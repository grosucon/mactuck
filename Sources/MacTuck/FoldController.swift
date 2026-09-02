import AppKit
import MacTuckCore

@MainActor
final class FoldController {
    var dropdownActions: (@MainActor () -> DropdownActions)?

    private(set) var currentItems: [MenuBarItemRef] = []

    private let reader: any MenuBarReading
    private let settings: AppSettings
    private let exclusions: Exclusions
    private let panel = CoverPanel()
    private let menuBuilder = ProxyMenuBuilder()
    private var timer: Timer?
    private var failures = 0
    private var lastRegularApp: NSRunningApplication?
    private var lastPlacement: CoverPlacement?

    init(reader: any MenuBarReading, settings: AppSettings, exclusions: Exclusions) {
        self.reader = reader
        self.settings = settings
        self.exclusions = exclusions
    }

    var owner: NSRunningApplication? {
        NSWorkspace.shared.menuBarOwningApplication ?? lastRegularApp
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
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.refresh() }
        }
        panel.cover.onClick = { [weak self] in self?.showDropdown() }
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
        guard let owner, let screen = NSScreen.screens.first else {
            hide()
            return
        }
        if let bundleID = owner.bundleIdentifier, exclusions.contains(bundleID) {
            hide()
            return
        }
        guard let snapshot = reader.snapshot(pid: owner.processIdentifier),
              let placement = CoverGeometry.placement(for: snapshot.layout, primaryScreen: screen.frame) else {
            failures += 1
            if failures >= 2 { hide() }
            return
        }
        failures = 0
        currentItems = Array(snapshot.items.dropFirst())

        if placement != lastPlacement {
            lastPlacement = placement
            Log.cover.debug("cover pid=\(owner.processIdentifier) x=\(placement.frame.minX) width=\(placement.frame.width)")
        }
        var frame = placement.frame
        panel.setFrame(frame, display: false)
        panel.cover.material = settings.material
        panel.cover.configure(appName: owner.localizedName ?? "App", pillX: placement.pillX)
        frame.size.width = max(frame.width, panel.cover.pillMaxX + CoverGeometry.padding)
        panel.setFrame(frame, display: true)
        panel.orderFrontRegardless()
    }

    func showDropdown() {
        guard let dropdownActions, let screen = NSScreen.screens.first else { return }
        let menu = menuBuilder.menu(items: currentItems, actions: dropdownActions())
        let anchor = NSPoint(
            x: panel.frame.minX + panel.cover.pillMinX,
            y: min(panel.frame.minY, screen.visibleFrame.maxY) - 12
        )
        menu.popUp(positioning: nil, at: anchor, in: nil)
    }

    func excludeOwner() {
        guard let bundleID = owner?.bundleIdentifier else { return }
        exclusions.add(bundleID)
        Log.cover.notice("excluded \(bundleID, privacy: .public)")
        refresh()
    }

    private func appActivated(pid: pid_t?) {
        if let pid, let app = NSRunningApplication(processIdentifier: pid), app.activationPolicy == .regular {
            lastRegularApp = app
        }
        scheduleRefresh()
    }

    private func hide() {
        failures = 0
        lastPlacement = nil
        panel.orderOut(nil)
    }
}
