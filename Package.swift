// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MacTuck",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "MacTuckCore", targets: ["MacTuckCore"]),
    ],
    targets: [
        .target(
            name: "MacTuckCore",
            path: "Sources/MacTuckCore",
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .executableTarget(
            name: "MacTuck",
            dependencies: ["MacTuckCore"],
            path: "Sources/MacTuck",
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "MacTuckCoreTests",
            dependencies: ["MacTuckCore"],
            path: "Tests/MacTuckCoreTests",
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
    ]
)
