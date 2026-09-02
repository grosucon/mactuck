import Foundation
import Observation

@MainActor
@Observable
public final class Exclusions {
    public static let key = "excludedBundleIDs"

    public private(set) var bundleIDs: Set<String>

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.bundleIDs = Set(defaults.stringArray(forKey: Self.key) ?? [])
    }

    public func contains(_ bundleID: String) -> Bool {
        bundleIDs.contains(bundleID)
    }

    public func add(_ bundleID: String) {
        bundleIDs.insert(bundleID)
        save()
    }

    public func remove(_ bundleID: String) {
        bundleIDs.remove(bundleID)
        save()
    }

    private func save() {
        defaults.set(bundleIDs.sorted(), forKey: Self.key)
    }
}
