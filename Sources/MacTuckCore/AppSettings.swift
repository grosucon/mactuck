import Foundation
import Observation

@MainActor
@Observable
public final class AppSettings {
    public static let materialKey = "stripMaterial"

    public var material: StripMaterial {
        didSet { defaults.set(material.rawValue, forKey: Self.materialKey) }
    }

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.material = defaults.string(forKey: Self.materialKey)
            .flatMap(StripMaterial.init(rawValue:)) ?? .hud
    }
}
