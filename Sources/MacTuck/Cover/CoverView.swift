import AppKit
import MacTuckCore

final class CoverView: NSView {
    var onClick: (@MainActor () -> Void)?

    var material: StripMaterial = .hud {
        didSet { applyMaterial() }
    }

    var pillMinX: CGFloat { pill.frame.minX }
    var pillMaxX: CGFloat { pill.frame.maxX }

    private let effect = NSVisualEffectView()
    private let solid = NSView()
    private let pill = PillView()
    private let label = NSTextField(labelWithString: "")

    override init(frame: NSRect) {
        super.init(frame: frame)
        wantsLayer = true

        effect.blendingMode = .behindWindow
        effect.state = .active
        addSubview(effect)

        solid.wantsLayer = true
        solid.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.85).cgColor
        addSubview(solid)

        addSubview(pill)

        label.font = .boldSystemFont(ofSize: NSFont.menuBarFont(ofSize: 0).pointSize)
        label.textColor = .labelColor
        pill.addSubview(label)

        applyMaterial()
    }

    required init?(coder: NSCoder) {
        fatalError("not supported")
    }

    func configure(appName: String, pillX: CGFloat) {
        label.stringValue = "\(appName) ▾"
        label.sizeToFit()
        let pillHeight = min(bounds.height - 8, 22)
        pill.frame = NSRect(
            x: pillX,
            y: (bounds.height - pillHeight) / 2,
            width: label.frame.width + 16,
            height: pillHeight
        )
        label.frame.origin = NSPoint(x: 8, y: (pillHeight - label.frame.height) / 2)
        pill.needsDisplay = true
    }

    override func layout() {
        super.layout()
        effect.frame = bounds
        solid.frame = bounds
    }

    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        if pill.frame.contains(point) { onClick?() }
    }

    private func applyMaterial() {
        if let visualEffectMaterial = material.visualEffectMaterial {
            effect.material = visualEffectMaterial
            effect.isHidden = false
            solid.isHidden = true
        } else {
            effect.isHidden = true
            solid.isHidden = false
        }
    }
}

private final class PillView: NSView {
    override func draw(_ dirtyRect: NSRect) {
        let isDark = effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        let fill = isDark ? NSColor.white.withAlphaComponent(0.16) : NSColor.black.withAlphaComponent(0.10)
        fill.setFill()
        NSBezierPath(roundedRect: bounds, xRadius: 6, yRadius: 6).fill()
    }
}
