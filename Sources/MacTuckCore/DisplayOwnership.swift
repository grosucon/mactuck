import CoreGraphics
import Foundation

public enum DisplayOwnership {
    public static let minimumSize = CGSize(width: 300, height: 200)

    public static func owns(_ window: CGRect, display: CGRect) -> Bool {
        guard window.width >= minimumSize.width, window.height >= minimumSize.height else { return false }
        let overlap = display.intersection(window)
        guard !overlap.isNull, !overlap.isEmpty else { return false }
        return overlap.width * overlap.height > window.width * window.height / 2
    }
}
