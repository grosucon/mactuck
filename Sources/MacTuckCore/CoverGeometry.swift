import CoreGraphics
import Foundation

public struct MenuBarLayout: Sendable, Equatable {
    public var barFrame: CGRect
    public var itemFrames: [CGRect]

    public init(barFrame: CGRect, itemFrames: [CGRect]) {
        self.barFrame = barFrame
        self.itemFrames = itemFrames
    }
}

public struct CoverPlacement: Sendable, Equatable {
    public var displayID: UInt32
    public var frame: CGRect
    public var pillX: CGFloat
    public var barHeight: CGFloat

    public init(displayID: UInt32, frame: CGRect, pillX: CGFloat, barHeight: CGFloat) {
        self.displayID = displayID
        self.frame = frame
        self.pillX = pillX
        self.barHeight = barHeight
    }
}

public struct DisplayMenuBar: Sendable, Equatable {
    public var displayID: UInt32
    public var barFrame: CGRect
    public var layout: MenuBarLayout

    public init(displayID: UInt32, barFrame: CGRect, layout: MenuBarLayout) {
        self.displayID = displayID
        self.barFrame = barFrame
        self.layout = layout
    }
}

public enum CoverGeometry {
    public static let padding: CGFloat = 6

    public static func placements(for bars: [DisplayMenuBar], primaryScreen: CGRect) -> [CoverPlacement] {
        bars.compactMap { bar in
            let visible = bar.layout.itemFrames.filter { $0.width > 0 }
            guard visible.count >= 2, let last = visible.last else { return nil }
            let appMenu = visible[1]
            let leftInset = appMenu.minX - bar.layout.barFrame.minX - padding
            let width = last.maxX - appMenu.minX + padding * 2
            let height = bar.barFrame.height
            let x = bar.barFrame.minX + leftInset
            let clampedWidth = max(0, min(width, bar.barFrame.maxX - x))
            return CoverPlacement(
                displayID: bar.displayID,
                frame: CGRect(
                    x: x,
                    y: primaryScreen.maxY - (bar.barFrame.minY + height),
                    width: clampedWidth,
                    height: height
                ),
                pillX: padding,
                barHeight: height
            )
        }
    }
}
