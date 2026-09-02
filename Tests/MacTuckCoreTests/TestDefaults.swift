import Foundation
import XCTest

func withTemporaryDefaults(_ body: (UserDefaults) -> Void) {
    let name = "MacTuckTests-\(UUID().uuidString)"
    guard let defaults = UserDefaults(suiteName: name) else {
        return XCTFail("could not open a throwaway defaults suite")
    }
    defer { defaults.removePersistentDomain(forName: name) }
    body(defaults)
}
