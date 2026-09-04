import CoreGraphics
import XCTest
@testable import MacTuckCore

final class MenuBarWindowsTests: XCTestCase {
    private let primary = CGRect(x: 0, y: 0, width: 1512, height: 982)
    private let builtIn = ScreenInfo(displayID: 1, frame: CGRect(x: 0, y: 0, width: 1512, height: 982))
    private let above = ScreenInfo(displayID: 2, frame: CGRect(x: 0, y: 982, width: 1920, height: 1080))
    private let aboveLeft = ScreenInfo(displayID: 3, frame: CGRect(x: -1920, y: 982, width: 1920, height: 1080))
    private let below = ScreenInfo(displayID: 4, frame: CGRect(x: 0, y: -1080, width: 1920, height: 1080))

    private let settled = [
        CGRect(x: 0, y: 0, width: 1512, height: 33),
        CGRect(x: 0, y: -1080, width: 1920, height: 30),
        CGRect(x: -1920, y: -1080, width: 1920, height: 30),
    ]

    func test_each_screen_gets_the_bar_at_its_own_top_left_corner() {
        let bars = MenuBarWindows.settledBars(candidates: settled, screens: [builtIn, above, aboveLeft], primaryScreen: primary)
        XCTAssertEqual(bars, [
            DisplayBar(displayID: 1, barFrame: CGRect(x: 0, y: 0, width: 1512, height: 33)),
            DisplayBar(displayID: 2, barFrame: CGRect(x: 0, y: -1080, width: 1920, height: 30)),
            DisplayBar(displayID: 3, barFrame: CGRect(x: -1920, y: -1080, width: 1920, height: 30)),
        ])
    }

    func test_part_slid_bars_are_rejected() {
        let sliding = [
            CGRect(x: 0, y: -22, width: 1512, height: 33),
            CGRect(x: 0, y: -1083, width: 1920, height: 30),
            CGRect(x: -1920, y: -1092, width: 1920, height: 30),
        ]
        XCTAssertEqual(MenuBarWindows.settledBars(candidates: sliding, screens: [builtIn, above, aboveLeft], primaryScreen: primary), [])
    }

    func test_a_sliding_space_leaves_only_the_settled_displays_covered() {
        let switching = [
            CGRect(x: -2898, y: -1080, width: 1920, height: 30),
            CGRect(x: -914, y: -1080, width: 1920, height: 30),
            CGRect(x: 0, y: -1080, width: 1920, height: 30),
            CGRect(x: 0, y: 0, width: 1512, height: 33),
        ]
        let bars = MenuBarWindows.settledBars(candidates: switching, screens: [builtIn, above, aboveLeft], primaryScreen: primary)
        XCTAssertEqual(bars.map(\.displayID), [1, 2])
    }

    func test_no_candidates_covers_nothing() {
        XCTAssertEqual(MenuBarWindows.settledBars(candidates: [], screens: [builtIn, above, aboveLeft], primaryScreen: primary), [])
    }

    func test_a_single_screen_is_matched_by_its_own_bar() {
        let bars = MenuBarWindows.settledBars(
            candidates: [CGRect(x: 0, y: 0, width: 1512, height: 33)],
            screens: [builtIn],
            primaryScreen: primary
        )
        XCTAssertEqual(bars, [DisplayBar(displayID: 1, barFrame: CGRect(x: 0, y: 0, width: 1512, height: 33))])
    }

    func test_one_point_off_is_accepted_and_three_points_off_is_not() {
        let near = CGRect(x: 0, y: -1081, width: 1920, height: 30)
        let far = CGRect(x: 0, y: -1083, width: 1920, height: 30)
        XCTAssertEqual(MenuBarWindows.settledBars(candidates: [near], screens: [above], primaryScreen: primary).count, 1)
        XCTAssertEqual(MenuBarWindows.settledBars(candidates: [far], screens: [above], primaryScreen: primary), [])
    }

    func test_a_bar_of_the_wrong_width_is_not_that_screen_s_bar() {
        let wrong = CGRect(x: 0, y: 0, width: 1920, height: 33)
        XCTAssertEqual(MenuBarWindows.settledBars(candidates: [wrong], screens: [builtIn], primaryScreen: primary), [])
    }

    func test_a_screen_below_the_primary_has_a_positive_origin_y() {
        let bars = MenuBarWindows.settledBars(
            candidates: [CGRect(x: 0, y: 982, width: 1920, height: 30)],
            screens: [below],
            primaryScreen: primary
        )
        XCTAssertEqual(bars, [DisplayBar(displayID: 4, barFrame: CGRect(x: 0, y: 982, width: 1920, height: 30))])
    }
}
