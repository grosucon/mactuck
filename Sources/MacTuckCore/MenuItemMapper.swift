public struct MenuItemAttributes: Sendable, Equatable {
    public var title: String?
    public var isEnabled: Bool?
    public var markCharacter: String?
    public var commandCharacter: String?
    public var commandModifiers: Int?
    public var virtualKey: Int?
    public var hasSubmenu: Bool

    public init(
        title: String? = nil,
        isEnabled: Bool? = nil,
        markCharacter: String? = nil,
        commandCharacter: String? = nil,
        commandModifiers: Int? = nil,
        virtualKey: Int? = nil,
        hasSubmenu: Bool = false
    ) {
        self.title = title
        self.isEnabled = isEnabled
        self.markCharacter = markCharacter
        self.commandCharacter = commandCharacter
        self.commandModifiers = commandModifiers
        self.virtualKey = virtualKey
        self.hasSubmenu = hasSubmenu
    }
}

public enum MenuItemMapper {
    public static func map(_ attributes: MenuItemAttributes) -> MenuNode {
        let title = attributes.title ?? ""
        if title.isEmpty && !attributes.hasSubmenu {
            return .separator
        }
        let keyEquivalent = keyEquivalent(for: attributes)
        return MenuNode(
            kind: attributes.hasSubmenu ? .submenu : .item,
            title: title,
            isEnabled: attributes.isEnabled ?? true,
            mark: mark(for: attributes.markCharacter),
            keyEquivalent: keyEquivalent,
            modifiers: keyEquivalent.isEmpty ? [] : modifiers(for: attributes.commandModifiers)
        )
    }

    static let virtualKeyGlyphs: [Int: String] = [
        123: "\u{F702}", 124: "\u{F703}", 125: "\u{F701}", 126: "\u{F700}",
        51: "\u{8}", 117: "\u{F728}", 36: "\r", 76: "\u{3}", 53: "\u{1B}", 48: "\t", 49: " ",
        115: "\u{F729}", 119: "\u{F72B}", 116: "\u{F72C}", 121: "\u{F72D}",
        122: "\u{F704}", 120: "\u{F705}", 99: "\u{F706}", 118: "\u{F707}", 96: "\u{F708}", 97: "\u{F709}",
        98: "\u{F70A}", 100: "\u{F70B}", 101: "\u{F70C}", 109: "\u{F70D}", 103: "\u{F70E}", 111: "\u{F70F}",
    ]

    private static func mark(for character: String?) -> MenuNode.Mark {
        guard let character, !character.isEmpty else { return .off }
        return character == "✓" ? .on : .mixed
    }

    private static func modifiers(for raw: Int?) -> KeyModifiers {
        let raw = raw ?? 0
        var modifiers: KeyModifiers = raw & (1 << 3) == 0 ? [.command] : []
        if raw & (1 << 0) != 0 { modifiers.insert(.shift) }
        if raw & (1 << 1) != 0 { modifiers.insert(.option) }
        if raw & (1 << 2) != 0 { modifiers.insert(.control) }
        return modifiers
    }

    private static func keyEquivalent(for attributes: MenuItemAttributes) -> String {
        if let character = attributes.commandCharacter, character.count == 1 {
            return character.lowercased()
        }
        if let virtualKey = attributes.virtualKey, let glyph = virtualKeyGlyphs[virtualKey] {
            return glyph
        }
        return ""
    }
}
