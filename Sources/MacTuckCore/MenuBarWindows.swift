import CoreGraphics
import Foundation

public struct ScreenInfo: Sendable, Equatable {
    public var displayID: UInt32
    public var frame: CGRect

    public init(displayID: UInt32, frame: CGRect) {
        self.displayID = displayID
        self.frame = frame
    }
}

public struct DisplayBar: Sendable, Equatable {
    public var displayID: UInt32
    public var barFrame: CGRect

    public init(displayID: UInt32, barFrame: CGRect) {
        self.displayID = displayID
        self.barFrame = barFrame
    }
}

public enum MenuBarWindows {
    public static let tolerance: CGFloat = 1

    public static func settledBars(
        candidates: [CGRect],
        screens: [ScreenInfo],
        primaryScreen: CGRect
    ) -> [DisplayBar] {
        screens.compactMap { screen in
            let originX = screen.frame.minX
            let originY = primaryScreen.maxY - screen.frame.maxY
            let match = candidates.first {
                abs($0.minX - originX) <= tolerance
                    && abs($0.minY - originY) <= tolerance
                    && abs($0.width - screen.frame.width) <= tolerance
            }
            guard let match else { return nil }
            return DisplayBar(displayID: screen.displayID, barFrame: match)
        }
    }
}
