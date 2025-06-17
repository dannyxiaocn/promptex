// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PromptEx",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "PromptEx", targets: ["PromptEx"])
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/KeyboardShortcuts", from: "1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "PromptEx",
            dependencies: ["KeyboardShortcuts"],
            path: "Sources"
        )
    ]
) 