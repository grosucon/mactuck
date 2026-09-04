import AppKit
import MacTuckCore

struct DisplayOwner: Equatable {
    let pid: pid_t
    let name: String
    let bundleID: String?
}

@MainActor
protocol DisplayOwnerReading {
    func owners(for screens: [ScreenInfo], primaryScreen: CGRect) -> [UInt32: DisplayOwner]
}

@MainActor
final class DisplayOwnerReader: DisplayOwnerReading {
    func owners(for screens: [ScreenInfo], primaryScreen: CGRect) -> [UInt32: DisplayOwner] {
        let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
        let list = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] ?? []
        var result: [UInt32: DisplayOwner] = [:]
        for screen in screens {
            let area = CGRect(
                x: screen.frame.minX,
                y: primaryScreen.maxY - screen.frame.maxY,
                width: screen.frame.width,
                height: screen.frame.height
            )
            for window in list {
                guard window[kCGWindowLayer as String] as? Int == 0,
                      let pid = window[kCGWindowOwnerPID as String] as? pid_t,
                      let bounds = window[kCGWindowBounds as String] as? [String: CGFloat],
                      let x = bounds["X"], let y = bounds["Y"],
                      let width = bounds["Width"], let height = bounds["Height"]
                else { continue }
                guard DisplayOwnership.owns(CGRect(x: x, y: y, width: width, height: height), display: area) else { continue }
                guard let app = NSRunningApplication(processIdentifier: pid), app.activationPolicy == .regular else { continue }
                result[screen.displayID] = DisplayOwner(
                    pid: pid,
                    name: app.localizedName ?? "App",
                    bundleID: app.bundleIdentifier
                )
                break
            }
        }
        return result
    }
}
