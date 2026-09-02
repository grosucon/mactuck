import AppKit
import ApplicationServices
import SwiftUI

@MainActor
final class AccessibilityGate {
    private let onTrusted: @MainActor () -> Void
    private var window: NSWindow?
    private var timer: Timer?

    init(onTrusted: @escaping @MainActor () -> Void) {
        self.onTrusted = onTrusted
    }

    func begin() {
        let options = ["AXTrustedCheckOptionPrompt" as CFString: true] as CFDictionary
        if AXIsProcessTrustedWithOptions(options) {
            onTrusted()
            return
        }
        Log.app.notice("accessibility not granted, waiting")
        showWindow()
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.poll() }
        }
    }

    private func poll() {
        guard AXIsProcessTrusted() else { return }
        timer?.invalidate()
        timer = nil
        window?.close()
        window = nil
        Log.app.notice("accessibility granted")
        onTrusted()
    }

    private func showWindow() {
        let view = AccessibilityGateView {
            let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
            NSWorkspace.shared.open(url)
        }
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 440, height: 200),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "MacTuck"
        window.isReleasedWhenClosed = false
        window.contentViewController = NSHostingController(rootView: view)
        window.center()
        window.level = .floating
        self.window = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

private struct AccessibilityGateView: View {
    let openSettings: @MainActor () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MacTuck needs Accessibility").font(.title3.bold())
            Text("MacTuck reads the menu bar of the app you are using and triggers its menu items for you. macOS calls that Accessibility. Nothing leaves your Mac.")
            Text("Open System Settings › Privacy & Security › Accessibility and switch on MacTuck. This window closes by itself once that is done.")
            HStack {
                Spacer()
                Button("Open System Settings", action: openSettings).keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(width: 440)
    }
}
