import XCTest
@testable import MacTuckCore

@MainActor
final class ExclusionsTests: XCTestCase {
    func test_starts_empty() {
        withTemporaryDefaults { defaults in
            XCTAssertTrue(Exclusions(defaults: defaults).bundleIDs.isEmpty)
        }
    }

    func test_add_and_remove_persist_across_instances() {
        withTemporaryDefaults { defaults in
            let first = Exclusions(defaults: defaults)
            first.add("com.google.Chrome")
            first.add("com.apple.dt.Xcode")
            XCTAssertTrue(Exclusions(defaults: defaults).contains("com.google.Chrome"))

            first.remove("com.google.Chrome")
            let second = Exclusions(defaults: defaults)
            XCTAssertFalse(second.contains("com.google.Chrome"))
            XCTAssertEqual(second.bundleIDs, ["com.apple.dt.Xcode"])
        }
    }
}
