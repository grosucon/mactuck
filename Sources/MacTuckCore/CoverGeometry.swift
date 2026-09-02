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
    public var frame: CGRect
    public var pillX: CGFloat
    public var barHeight: CGFloat

    public init(frame: CGRect, pillX: CGFloat, barHeight: CGFloat) {
        self.frame = frame
        self.pillX = pillX
        self.barHeight = barHeight
    }
}

public enum CoverGeometry {
    public static let padding: CGFloat = 6

    public static func placement(for layout: MenuBarLayout, primaryScreen: CGRect) -> CoverPlacement? {
        guard layout.barFrame.minY == 0 else { return nil }
        let visible = layout.itemFrames.filter { $0.width > 0 }
        guard visible.count >= 2, let last = visible.last else { return nil }
        let appMenu = visible[1]
        let minX = appMenu.minX - padding
        let width = last.maxX - appMenu.minX + padding * 2
        let height = layout.barFrame.height
        let cocoaY = primaryScreen.maxY - (layout.barFrame.minY + height)
        return CoverPlacement(
            frame: CGRect(x: minX, y: cocoaY, width: width, height: height),
            pillX: padding,
            barHeight: height
        )
    }
}
