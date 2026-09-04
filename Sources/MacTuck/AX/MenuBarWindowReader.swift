import CoreGraphics
import Foundation

@MainActor
protocol MenuBarWindowReading {
    func barCandidates() -> [CGRect]
}

@MainActor
final class MenuBarWindowReader: MenuBarWindowReading {
    private let level = Int(CGWindowLevelForKey(.mainMenuWindow))

    func barCandidates() -> [CGRect] {
        let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
        let list = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] ?? []
        return list.compactMap { window in
            guard window[kCGWindowOwnerName as String] as? String == "Window Server",
                  window[kCGWindowLayer as String] as? Int == level,
                  let bounds = window[kCGWindowBounds as String] as? [String: CGFloat],
                  let x = bounds["X"], let y = bounds["Y"],
                  let width = bounds["Width"], let height = bounds["Height"]
            else { return nil }
            return CGRect(x: x, y: y, width: width, height: height)
        }
    }
}
