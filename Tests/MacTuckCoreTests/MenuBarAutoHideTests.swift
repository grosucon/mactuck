import XCTest
@testable import MacTuckCore

final class MenuBarAutoHideTests: XCTestCase {
    func test_key_true_auto_hides() {
        XCTAssertTrue(MenuBarAutoHide.isEnabled(in: ["_HIHideMenuBar": true]))
    }

    func test_key_false_does_not_auto_hide() {
        XCTAssertFalse(MenuBarAutoHide.isEnabled(in: ["_HIHideMenuBar": false]))
    }

    func test_absent_key_does_not_auto_hide() {
        XCTAssertFalse(MenuBarAutoHide.isEnabled(in: [:]))
        XCTAssertFalse(MenuBarAutoHide.isEnabled(in: nil))
    }

    func test_non_boolean_value_does_not_auto_hide() {
        XCTAssertFalse(MenuBarAutoHide.isEnabled(in: ["_HIHideMenuBar": "yes"]))
    }
}
