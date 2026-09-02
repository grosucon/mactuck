import AppKit
import MacTuckCore
import SwiftUI

@MainActor
final class SettingsWindowController {
    private let window: NSWindow

    init(settings: AppSettings, exclusions: Exclusions, loginItem: LoginItem) {
        let view = SettingsView(settings: settings, exclusions: exclusions, loginItem: loginItem)
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 460, height: 420),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "MacTuck Settings"
        window.isReleasedWhenClosed = false
        window.contentViewController = NSHostingController(rootView: view)
        window.center()
    }

    func show() {
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
