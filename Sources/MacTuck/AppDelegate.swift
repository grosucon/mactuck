import AppKit
import MacTuckCore

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let settings = AppSettings()
    private let exclusions = Exclusions()
    private let loginItem = LoginItem()
    private var gate: AccessibilityGate?
    private var fold: FoldController?
    private var settingsWindow: SettingsWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        Log.app.notice("launch")
        let gate = AccessibilityGate { [weak self] in self?.start() }
        self.gate = gate
        gate.begin()
    }

    private func start() {
        let fold = FoldController(
            reader: MenuBarReader(),
            windows: MenuBarWindowReader(),
            ownerReader: DisplayOwnerReader(),
            settings: settings,
            exclusions: exclusions
        )
        fold.dropdownActions = { [weak self, weak fold] owner in
            DropdownActions(
                excludeTitle: "Exclude \(owner.name)",
                onExclude: {
                    guard let bundleID = owner.bundleID else { return }
                    fold?.exclude(bundleID: bundleID)
                },
                onSettings: { self?.showSettings() },
                onQuit: { NSApp.terminate(nil) }
            )
        }
        self.fold = fold
        fold.start()
        Log.app.notice("started")
    }

    private func showSettings() {
        if settingsWindow == nil {
            settingsWindow = SettingsWindowController(settings: settings, exclusions: exclusions, loginItem: loginItem)
        }
        settingsWindow?.show()
    }
}
