import AppKit
import MacTuckCore

extension StripMaterial {
    var visualEffectMaterial: NSVisualEffectView.Material? {
        switch self {
        case .hud: .hudWindow
        case .menu: .menu
        case .popover: .popover
        case .sidebar: .sidebar
        case .titlebar: .titlebar
        case .header: .headerView
        case .windowBackground: .windowBackground
        case .underWindow: .underWindowBackground
        case .solid: nil
        }
    }
}
