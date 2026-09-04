public enum MenuBarAutoHide {
    public static func isEnabled(in domain: [String: Any]?) -> Bool {
        domain?["_HIHideMenuBar"] as? Bool ?? false
    }
}
