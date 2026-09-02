import XCTest
@testable import MacTuckCore

@MainActor
final class AppSettingsTests: XCTestCase {
    func test_defaults_to_hud() {
        withTemporaryDefaults { defaults in
            XCTAssertEqual(AppSettings(defaults: defaults).material, .hud)
        }
    }

    func test_material_persists() {
        withTemporaryDefaults { defaults in
            AppSettings(defaults: defaults).material = .sidebar
            XCTAssertEqual(AppSettings(defaults: defaults).material, .sidebar)
        }
    }

    func test_garbage_value_falls_back_to_hud() {
        withTemporaryDefaults { defaults in
            defaults.set("marble", forKey: AppSettings.materialKey)
            XCTAssertEqual(AppSettings(defaults: defaults).material, .hud)
        }
    }
}
