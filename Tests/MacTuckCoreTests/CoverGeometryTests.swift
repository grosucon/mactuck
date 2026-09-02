import CoreGraphics
import XCTest
@testable import MacTuckCore

final class CoverGeometryTests: XCTestCase {
    private let screen = CGRect(x: 0, y: 0, width: 1512, height: 982)
    private let apple = CGRect(x: 10, y: 0, width: 28, height: 33)

    private func layout(barY: CGFloat = 0, items: [CGRect]) -> MenuBarLayout {
        MenuBarLayout(barFrame: CGRect(x: 0, y: barY, width: 1512, height: 33), itemFrames: items)
    }

    func test_spans_app_menu_to_last_item_with_padding_in_cocoa_coordinates() {
        let items = [
            apple,
            CGRect(x: 44, y: 0, width: 60, height: 33),
            CGRect(x: 110, y: 0, width: 40, height: 33),
            CGRect(x: 588, y: 0, width: 40, height: 33),
        ]
        let placement = CoverGeometry.placement(for: layout(items: items), primaryScreen: screen)
        XCTAssertEqual(placement?.frame, CGRect(x: 38, y: 949, width: 596, height: 33))
        XCTAssertEqual(placement?.pillX, 6)
        XCTAssertEqual(placement?.barHeight, 33)
    }

    func test_zero_width_items_are_ignored() {
        let items = [
            apple,
            CGRect(x: 44, y: 0, width: 60, height: 33),
            CGRect(x: 588, y: 0, width: 40, height: 33),
            CGRect(x: 700, y: 0, width: 0, height: 33),
        ]
        let placement = CoverGeometry.placement(for: layout(items: items), primaryScreen: screen)
        XCTAssertEqual(placement?.frame, CGRect(x: 38, y: 949, width: 596, height: 33))
    }

    func test_hidden_menu_bar_yields_nil() {
        let items = [apple, CGRect(x: 44, y: -33, width: 60, height: 33)]
        XCTAssertNil(CoverGeometry.placement(for: layout(barY: -33, items: items), primaryScreen: screen))
    }

    func test_fewer_than_two_visible_items_yields_nil() {
        XCTAssertNil(CoverGeometry.placement(for: layout(items: [apple]), primaryScreen: screen))
        XCTAssertNil(CoverGeometry.placement(for: layout(items: []), primaryScreen: screen))
    }
}
