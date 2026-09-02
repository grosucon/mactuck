import ApplicationServices
import Foundation
import MacTuckCore

extension AXUIElement {
    func attribute<T>(_ name: String) -> T? {
        var value: CFTypeRef?
        guard AXUIElementCopyAttributeValue(self, name as CFString, &value) == .success else { return nil }
        return value as? T
    }

    var children: [AXUIElement] {
        attribute(kAXChildrenAttribute) ?? []
    }

    var role: String? {
        attribute(kAXRoleAttribute)
    }

    var title: String? {
        attribute(kAXTitleAttribute)
    }

    var frame: CGRect? {
        guard let position: AnyObject = attribute(kAXPositionAttribute),
              let size: AnyObject = attribute(kAXSizeAttribute),
              CFGetTypeID(position) == AXValueGetTypeID(),
              CFGetTypeID(size) == AXValueGetTypeID() else { return nil }
        var point = CGPoint.zero
        var extent = CGSize.zero
        AXValueGetValue(position as! AXValue, .cgPoint, &point)
        AXValueGetValue(size as! AXValue, .cgSize, &extent)
        return CGRect(origin: point, size: extent)
    }

    var menuChild: AXUIElement? {
        children.first { $0.role == kAXMenuRole }
    }

    func press() -> AXError {
        AXUIElementPerformAction(self, kAXPressAction as CFString)
    }

    func menuItemAttributes() -> MenuItemAttributes {
        let names = [
            kAXTitleAttribute, kAXEnabledAttribute, kAXMenuItemMarkCharAttribute,
            kAXMenuItemCmdCharAttribute, kAXMenuItemCmdModifiersAttribute,
            kAXMenuItemCmdVirtualKeyAttribute, kAXChildrenAttribute,
        ] as CFArray
        var values: CFArray?
        guard AXUIElementCopyMultipleAttributeValues(self, names, [], &values) == .success,
              let list = values as? [AnyObject], list.count == 7 else {
            return MenuItemAttributes()
        }
        let kids = list[6] as? [AXUIElement] ?? []
        return MenuItemAttributes(
            title: list[0] as? String,
            isEnabled: list[1] as? Bool,
            markCharacter: list[2] as? String,
            commandCharacter: list[3] as? String,
            commandModifiers: list[4] as? Int,
            virtualKey: list[5] as? Int,
            hasSubmenu: kids.contains { $0.role == kAXMenuRole }
        )
    }
}
