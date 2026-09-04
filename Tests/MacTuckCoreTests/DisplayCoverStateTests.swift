import XCTest
@testable import MacTuckCore

final class DisplayCoverStateTests: XCTestCase {
    func test_a_covered_display_is_neither_hidden_nor_dropped() {
        var state = DisplayCoverState()
        let update = state.update(covered: [1], liveDisplays: [1], panelDisplays: [1])
        XCTAssertEqual(update.hide, [])
        XCTAssertEqual(update.drop, [])
    }

    func test_a_missing_bar_hides_only_on_the_second_consecutive_miss() {
        var state = DisplayCoverState()
        XCTAssertEqual(state.update(covered: [], liveDisplays: [1], panelDisplays: [1]).hide, [])
        XCTAssertEqual(state.update(covered: [], liveDisplays: [1], panelDisplays: [1]).hide, [1])
    }

    func test_a_recovered_bar_resets_the_miss_count() {
        var state = DisplayCoverState()
        _ = state.update(covered: [], liveDisplays: [1], panelDisplays: [1])
        _ = state.update(covered: [1], liveDisplays: [1], panelDisplays: [1])
        XCTAssertEqual(state.update(covered: [], liveDisplays: [1], panelDisplays: [1]).hide, [])
    }

    func test_one_display_missing_does_not_hide_another() {
        var state = DisplayCoverState()
        _ = state.update(covered: [1], liveDisplays: [1, 2], panelDisplays: [1, 2])
        let update = state.update(covered: [1], liveDisplays: [1, 2], panelDisplays: [1, 2])
        XCTAssertEqual(update.hide, [2])
    }

    func test_a_disconnected_display_is_dropped_without_a_debounce() {
        var state = DisplayCoverState()
        let update = state.update(covered: [], liveDisplays: [], panelDisplays: [1])
        XCTAssertEqual(update.drop, [1])
        XCTAssertEqual(update.hide, [])
    }

    func test_reset_forgets_every_miss() {
        var state = DisplayCoverState()
        _ = state.update(covered: [], liveDisplays: [1], panelDisplays: [1])
        state.reset()
        XCTAssertEqual(state.update(covered: [], liveDisplays: [1], panelDisplays: [1]).hide, [])
    }

    func test_a_display_without_a_panel_is_never_hidden() {
        var state = DisplayCoverState()
        let update = state.update(covered: [], liveDisplays: [1, 2], panelDisplays: [])
        XCTAssertEqual(update.hide, [])
        XCTAssertEqual(update.drop, [])
    }
}
