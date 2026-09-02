public enum StripMaterial: String, CaseIterable, Codable, Sendable {
    case hud, menu, popover, sidebar, titlebar, header, windowBackground, underWindow, solid

    public var label: String {
        switch self {
        case .hud: "HUD"
        case .menu: "Menu"
        case .popover: "Popover"
        case .sidebar: "Sidebar"
        case .titlebar: "Titlebar"
        case .header: "Header"
        case .windowBackground: "Window background"
        case .underWindow: "Under window"
        case .solid: "Solid"
        }
    }
}
