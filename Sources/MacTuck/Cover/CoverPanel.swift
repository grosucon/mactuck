import AppKit

final class CoverPanel: NSPanel {
    let cover = CoverView(frame: NSRect(x: 0, y: 0, width: 400, height: 24))

    init() {
        super.init(
            contentRect: cover.frame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        hidesOnDeactivate = false
        isFloatingPanel = true
        isMovable = false
        isReleasedWhenClosed = false
        level = .statusBar
        collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        contentView = cover
    }

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}
