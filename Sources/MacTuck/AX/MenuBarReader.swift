import ApplicationServices
import Foundation
import MacTuckCore

struct MenuBarItemRef {
    let title: String
    let frame: CGRect
    let element: AXUIElement
}

struct MenuBarSnapshot {
    let barFrame: CGRect
    let items: [MenuBarItemRef]

    var layout: MenuBarLayout {
        MenuBarLayout(barFrame: barFrame, itemFrames: items.map(\.frame))
    }
}

@MainActor
protocol MenuBarReading {
    func snapshot(pid: pid_t) -> MenuBarSnapshot?
}

@MainActor
final class MenuBarReader: MenuBarReading {
    func snapshot(pid: pid_t) -> MenuBarSnapshot? {
        let application = AXUIElementCreateApplication(pid)
        guard let bar: AXUIElement = application.attribute(kAXMenuBarAttribute),
              let barFrame = bar.frame else { return nil }
        let items = bar.children.compactMap { element -> MenuBarItemRef? in
            guard let frame = element.frame else { return nil }
            return MenuBarItemRef(title: element.title ?? "", frame: frame, element: element)
        }
        return MenuBarSnapshot(barFrame: barFrame, items: items)
    }
}
