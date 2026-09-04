import CoreGraphics
import XCTest
@testable import MacTuckCore

final class DisplayOwnershipTests: XCTestCase {
    private let builtIn = CGRect(x: 0, y: 0, width: 1512, height: 982)
    private let above = CGRect(x: -919, y: -1440, width: 3440, height: 1440)

    func test_a_window_filling_a_display_belongs_to_it() {
        XCTAssertTrue(DisplayOwnership.owns(CGRect(x: 0, y: 33, width: 1512, height: 949), display: builtIn))
        XCTAssertTrue(DisplayOwnership.owns(CGRect(x: -919, y: -1410, width: 3440, height: 1410), display: above))
    }

    func test_a_window_on_another_display_does_not_belong() {
        XCTAssertFalse(DisplayOwnership.owns(CGRect(x: -919, y: -1410, width: 3440, height: 1410), display: builtIn))
        XCTAssertFalse(DisplayOwnership.owns(CGRect(x: 0, y: 33, width: 1512, height: 949), display: above))
    }

    func test_a_window_straddling_two_displays_belongs_to_the_one_holding_most_of_it() {
        let mostlyBelowTheSeam = CGRect(x: 0, y: -200, width: 1000, height: 800)
        XCTAssertTrue(DisplayOwnership.owns(mostlyBelowTheSeam, display: builtIn))
        XCTAssertFalse(DisplayOwnership.owns(mostlyBelowTheSeam, display: above))

        let mostlyAboveTheSeam = CGRect(x: 0, y: -600, width: 1000, height: 800)
        XCTAssertTrue(DisplayOwnership.owns(mostlyAboveTheSeam, display: above))
        XCTAssertFalse(DisplayOwnership.owns(mostlyAboveTheSeam, display: builtIn))
    }

    func test_small_windows_are_not_owners() {
        XCTAssertFalse(DisplayOwnership.owns(CGRect(x: 10, y: 40, width: 299, height: 900), display: builtIn))
        XCTAssertFalse(DisplayOwnership.owns(CGRect(x: 10, y: 40, width: 900, height: 199), display: builtIn))
    }

    func test_a_window_that_does_not_touch_the_display_is_rejected() {
        XCTAssertFalse(DisplayOwnership.owns(CGRect(x: 5000, y: 5000, width: 800, height: 600), display: builtIn))
    }
}
