import XCTest
@testable import MacTuckCore

final class MenuItemMapperTests: XCTestCase {
    func test_empty_title_without_submenu_is_a_separator() {
        let node = MenuItemMapper.map(MenuItemAttributes(title: ""))
        XCTAssertEqual(node, .separator)
    }

    func test_plain_item_is_enabled_with_no_shortcut() {
        let node = MenuItemMapper.map(MenuItemAttributes(title: "New Window"))
        XCTAssertEqual(node.kind, .item)
        XCTAssertEqual(node.title, "New Window")
        XCTAssertTrue(node.isEnabled)
        XCTAssertEqual(node.keyEquivalent, "")
        XCTAssertEqual(node.modifiers, [])
    }

    func test_command_character_is_lowercased_and_implies_command() {
        let node = MenuItemMapper.map(MenuItemAttributes(title: "Undo", commandCharacter: "Z", commandModifiers: 0))
        XCTAssertEqual(node.keyEquivalent, "z")
        XCTAssertEqual(node.modifiers, [.command])
    }

    func test_modifier_bits_map_to_shift_option_control() {
        let node = MenuItemMapper.map(MenuItemAttributes(title: "Redo", commandCharacter: "Z", commandModifiers: 0b111))
        XCTAssertEqual(node.modifiers, [.command, .shift, .option, .control])
    }

    func test_no_command_bit_drops_command() {
        let node = MenuItemMapper.map(MenuItemAttributes(title: "Delete", commandCharacter: "\u{8}", commandModifiers: 0b1000))
        XCTAssertEqual(node.keyEquivalent, "\u{8}")
        XCTAssertEqual(node.modifiers, [])
    }

    func test_virtual_key_maps_to_function_key_character() {
        let node = MenuItemMapper.map(MenuItemAttributes(title: "Next Tab", commandCharacter: "", commandModifiers: 0, virtualKey: 124))
        XCTAssertEqual(node.keyEquivalent, "\u{F703}")
        XCTAssertEqual(node.modifiers, [.command])
    }

    func test_unknown_virtual_key_yields_no_shortcut() {
        let node = MenuItemMapper.map(MenuItemAttributes(title: "Odd", commandModifiers: 0, virtualKey: 999))
        XCTAssertEqual(node.keyEquivalent, "")
        XCTAssertEqual(node.modifiers, [])
    }

    func test_disabled_flag_is_respected() {
        let node = MenuItemMapper.map(MenuItemAttributes(title: "Show All", isEnabled: false))
        XCTAssertFalse(node.isEnabled)
    }

    func test_marks() {
        XCTAssertEqual(MenuItemMapper.map(MenuItemAttributes(title: "A", markCharacter: "✓")).mark, .on)
        XCTAssertEqual(MenuItemMapper.map(MenuItemAttributes(title: "B", markCharacter: "-")).mark, .mixed)
        XCTAssertEqual(MenuItemMapper.map(MenuItemAttributes(title: "C")).mark, .off)
    }

    func test_submenu_flag_makes_a_submenu_even_with_empty_title() {
        let node = MenuItemMapper.map(MenuItemAttributes(title: "", hasSubmenu: true))
        XCTAssertEqual(node.kind, .submenu)
    }
}
