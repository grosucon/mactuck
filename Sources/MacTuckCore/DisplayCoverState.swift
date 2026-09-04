import Foundation

public struct CoverUpdate: Sendable, Equatable {
    public var hide: [UInt32]
    public var drop: [UInt32]

    public init(hide: [UInt32], drop: [UInt32]) {
        self.hide = hide
        self.drop = drop
    }
}

public struct DisplayCoverState: Sendable {
    public static let strikes = 2

    private var misses: [UInt32: Int] = [:]

    public init() {}

    public mutating func reset() {
        misses.removeAll()
    }

    public mutating func update(
        covered: Set<UInt32>,
        liveDisplays: Set<UInt32>,
        panelDisplays: Set<UInt32>
    ) -> CoverUpdate {
        for displayID in covered {
            misses[displayID] = 0
        }
        let drop = panelDisplays.subtracting(liveDisplays).sorted()
        for displayID in drop {
            misses[displayID] = nil
        }
        var hide: [UInt32] = []
        for displayID in panelDisplays.intersection(liveDisplays).subtracting(covered).sorted() {
            let count = (misses[displayID] ?? 0) + 1
            misses[displayID] = count
            if count >= Self.strikes {
                hide.append(displayID)
            }
        }
        return CoverUpdate(hide: hide, drop: drop)
    }
}
