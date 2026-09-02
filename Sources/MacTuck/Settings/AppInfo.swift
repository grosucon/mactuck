import AppKit

enum AppInfo {
    static func lookup(bundleID: String) -> (name: String, icon: NSImage?) {
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else {
            return (bundleID, nil)
        }
        let name = FileManager.default.displayName(atPath: url.path)
            .replacingOccurrences(of: ".app", with: "")
        return (name, NSWorkspace.shared.icon(forFile: url.path))
    }
}
