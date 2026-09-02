import AppKit
import ApplicationServices
import MacTuckCore

@MainActor
struct DropdownActions {
    var excludeTitle: String
    var onExclude: @MainActor () -> Void
    var onSettings: @MainActor () -> Void
    var onQuit: @MainActor () -> Void
}

final class ProxyMenu: NSMenu {
    let source: AXUIElement

    init(title: String, source: AXUIElement) {
        self.source = source
        super.init(title: title)
        autoenablesItems = false
    }

    required init(coder: NSCoder) {
        fatalError("not supported")
    }
}

final class AXElementBox {
    let element: AXUIElement

    init(_ element: AXUIElement) {
        self.element = element
    }
}

@MainActor
final class ProxyMenuBuilder: NSObject, NSMenuDelegate {
    private var actions: DropdownActions?

    func menu(items: [MenuBarItemRef], actions: DropdownActions) -> NSMenu {
        self.actions = actions
        let menu = NSMenu()
        menu.autoenablesItems = false
        for ref in items {
            let item = NSMenuItem(title: ref.title, action: nil, keyEquivalent: "")
            item.submenu = proxyMenu(title: ref.title, source: ref.element)
            menu.addItem(item)
        }
        menu.addItem(.separator())

        let exclude = NSMenuItem(title: actions.excludeTitle, action: #selector(exclude(_:)), keyEquivalent: "")
        exclude.target = self
        menu.addItem(exclude)

        let settings = NSMenuItem(title: "MacTuck Settings…", action: #selector(openSettings(_:)), keyEquivalent: ",")
        settings.target = self
        menu.addItem(settings)

        let quit = NSMenuItem(title: "Quit MacTuck", action: #selector(quit(_:)), keyEquivalent: "")
        quit.target = self
        menu.addItem(quit)
        return menu
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        guard let proxy = menu as? ProxyMenu else { return }
        proxy.removeAllItems()
        guard let axMenu = proxy.source.menuChild else {
            Log.menu.error("no AXMenu child while opening a submenu")
            return
        }
        for element in axMenu.children {
            let node = MenuItemMapper.map(element.menuItemAttributes())
            proxy.addItem(menuItem(for: node, element: element))
        }
    }

    private func proxyMenu(title: String, source: AXUIElement) -> ProxyMenu {
        let menu = ProxyMenu(title: title, source: source)
        menu.delegate = self
        return menu
    }

    private func menuItem(for node: MenuNode, element: AXUIElement) -> NSMenuItem {
        switch node.kind {
        case .separator:
            return .separator()
        case .submenu:
            let item = NSMenuItem(title: node.title, action: nil, keyEquivalent: "")
            item.isEnabled = node.isEnabled
            item.submenu = proxyMenu(title: node.title, source: element)
            return item
        case .item:
            let item = NSMenuItem(title: node.title, action: #selector(press(_:)), keyEquivalent: node.keyEquivalent)
            item.keyEquivalentModifierMask = node.modifiers.eventFlags
            item.target = self
            item.representedObject = AXElementBox(element)
            item.isEnabled = node.isEnabled
            item.state = node.mark.controlState
            return item
        }
    }

    @objc private func press(_ sender: NSMenuItem) {
        guard let box = sender.representedObject as? AXElementBox else { return }
        let result = box.element.press()
        if result != .success {
            Log.menu.error("press failed: \(result.rawValue)")
        }
    }

    @objc private func exclude(_ sender: NSMenuItem) { actions?.onExclude() }
    @objc private func openSettings(_ sender: NSMenuItem) { actions?.onSettings() }
    @objc private func quit(_ sender: NSMenuItem) { actions?.onQuit() }
}

private extension MenuNode.Mark {
    var controlState: NSControl.StateValue {
        switch self {
        case .off: .off
        case .on: .on
        case .mixed: .mixed
        }
    }
}
