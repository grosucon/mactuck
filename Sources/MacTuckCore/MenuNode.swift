public struct MenuNode: Sendable, Equatable {
    public enum Kind: Sendable, Equatable {
        case item, separator, submenu
    }

    public enum Mark: Sendable, Equatable {
        case off, on, mixed
    }

    public var kind: Kind
    public var title: String
    public var isEnabled: Bool
    public var mark: Mark
    public var keyEquivalent: String
    public var modifiers: KeyModifiers

    public init(
        kind: Kind,
        title: String,
        isEnabled: Bool = true,
        mark: Mark = .off,
        keyEquivalent: String = "",
        modifiers: KeyModifiers = []
    ) {
        self.kind = kind
        self.title = title
        self.isEnabled = isEnabled
        self.mark = mark
        self.keyEquivalent = keyEquivalent
        self.modifiers = modifiers
    }

    public static let separator = MenuNode(kind: .separator, title: "")
}
