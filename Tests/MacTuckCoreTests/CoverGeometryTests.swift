import CoreGraphics
import XCTest
@testable import MacTuckCore

final class CoverGeometryTests: XCTestCase {
    private let primary = CGRect(x: 0, y: 0, width: 1512, height: 982)
    private let apple = CGRect(x: 10, y: 0, width: 28, height: 33)

    private var chromeItems: [CGRect] {
        [
            apple,
            CGRect(x: 44, y: 0, width: 60, height: 33),
            CGRect(x: 110, y: 0, width: 40, height: 33),
            CGRect(x: 588, y: 0, width: 40, height: 33),
        ]
    }

    private var rubyMineItems: [CGRect] {
        [
            apple,
            CGRect(x: 44, y: 0, width: 80, height: 33),
            CGRect(x: 130, y: 0, width: 40, height: 33),
            CGRect(x: 944, y: 0, width: 40, height: 33),
        ]
    }

    private func layout(
        barFrame: CGRect = CGRect(x: 0, y: 0, width: 1512, height: 33),
        items: [CGRect]
    ) -> MenuBarLayout {
        MenuBarLayout(barFrame: barFrame, itemFrames: items)
    }

    private func builtIn(_ items: [CGRect]) -> DisplayMenuBar {
        DisplayMenuBar(
            displayID: 1,
            barFrame: CGRect(x: 0, y: 0, width: 1512, height: 33),
            layout: layout(items: items)
        )
    }

    private func ultrawide(_ items: [CGRect]) -> DisplayMenuBar {
        DisplayMenuBar(
            displayID: 2,
            barFrame: CGRect(x: -919, y: -1440, width: 3440, height: 30),
            layout: layout(items: items)
        )
    }

    func test_spans_app_menu_to_last_item_with_padding_in_cocoa_coordinates() {
        let placements = CoverGeometry.placements(for: [builtIn(chromeItems)], primaryScreen: primary)
        XCTAssertEqual(placements, [
            CoverPlacement(
                displayID: 1,
                frame: CGRect(x: 38, y: 949, width: 596, height: 33),
                pillX: 6,
                barHeight: 33
            ),
        ])
    }

    func test_zero_width_items_are_ignored() {
        let items = [
            apple,
            CGRect(x: 44, y: 0, width: 60, height: 33),
            CGRect(x: 588, y: 0, width: 40, height: 33),
            CGRect(x: 700, y: 0, width: 0, height: 33),
        ]
        let placements = CoverGeometry.placements(for: [builtIn(items)], primaryScreen: primary)
        XCTAssertEqual(placements.first?.frame, CGRect(x: 38, y: 949, width: 596, height: 33))
    }

    func test_each_display_is_sized_from_its_own_owner_not_the_focused_one() {
        let placements = CoverGeometry.placements(
            for: [builtIn(chromeItems), ultrawide(rubyMineItems)],
            primaryScreen: primary
        )
        XCTAssertEqual(placements.map(\.frame), [
            CGRect(x: 38, y: 949, width: 596, height: 33),
            CGRect(x: -881, y: 2392, width: 952, height: 30),
        ])
    }

    func test_each_bar_keeps_its_own_height() {
        let placements = CoverGeometry.placements(
            for: [builtIn(chromeItems), ultrawide(chromeItems)],
            primaryScreen: primary
        )
        XCTAssertEqual(placements.map(\.barHeight), [33, 30])
    }

    func test_a_span_measured_left_of_the_origin_is_relative_to_its_own_bar() {
        let leftBar = CGRect(x: -1920, y: -1080, width: 1920, height: 30)
        let items = [
            CGRect(x: -1910, y: -1080, width: 28, height: 30),
            CGRect(x: -1876, y: -1080, width: 60, height: 30),
            CGRect(x: -1332, y: -1080, width: 40, height: 30),
        ]
        let bar = DisplayMenuBar(displayID: 3, barFrame: leftBar, layout: layout(barFrame: leftBar, items: items))
        let placements = CoverGeometry.placements(for: [bar], primaryScreen: primary)
        XCTAssertEqual(placements.map(\.frame), [CGRect(x: -1882, y: 2032, width: 596, height: 30)])
    }

    func test_the_span_never_runs_past_its_own_bar() {
        let narrow = DisplayMenuBar(
            displayID: 4,
            barFrame: CGRect(x: 0, y: -300, width: 300, height: 24),
            layout: layout(items: chromeItems)
        )
        let placements = CoverGeometry.placements(for: [narrow], primaryScreen: primary)
        XCTAssertEqual(placements.map(\.frame), [CGRect(x: 38, y: 1258, width: 262, height: 24)])
    }

    func test_a_bar_with_fewer_than_two_visible_items_is_skipped_without_losing_the_others() {
        let placements = CoverGeometry.placements(
            for: [ultrawide([apple]), builtIn(chromeItems)],
            primaryScreen: primary
        )
        XCTAssertEqual(placements.map(\.displayID), [1])
    }

    func test_no_bars_yields_no_placements() {
        XCTAssertEqual(CoverGeometry.placements(for: [], primaryScreen: primary), [])
    }
}
