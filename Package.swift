// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Joyfill",
    platforms: [
        .iOS(.v15), // Set the minimum deployment target to iOS 15
        .macOS(.v10_15) // Added macOS support for JoyfillFormulas
    ],
    products: [
        .library(
            name: "Joyfill",
            targets: ["Joyfill"]),
        .library(
            name: "JoyfillModel",
            targets: ["JoyfillModel"]),
        .library(
            name: "JoyfillFormulas",
            targets: ["JoyfillFormulas"]),
        .library(
            name: "JoyfillAPIService",
            targets: ["JoyfillAPIService"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kylef/JSONSchema.swift", .upToNextMajor(from: "0.6.0")),
    ],
    targets: [
        // Core JoyfillModel target (no dependencies)
        .target(
            name: "JoyfillModel",
            dependencies: []
        ),
        // JoyfillFormulas target (depends on JoyfillModel)
        .target(
            name: "JoyfillFormulas",
            dependencies: ["JoyfillModel"]
        ),
        // JoyfillAPIService target (depends on JoyfillModel)
        .target(
            name: "JoyfillAPIService",
            dependencies: ["JoyfillModel"]
        ),
        // Main Joyfill target (depends on all other internal modules)
        .target(
            name: "Joyfill",
            dependencies: [
                .product(name: "JSONSchema", package: "JSONSchema.swift"),
                "JoyfillModel",
                "JoyfillFormulas",
                "JoyfillAPIService",
            ],
            path: "Sources/JoyfillUI"
        ),
        // Test targets
        .testTarget(
            name: "JoyfillTests",
            dependencies: ["Joyfill"],
            path: "Tests/JoyfillUITests"
        ),
        .testTarget(
            name: "JoyfillModelTests",
            dependencies: ["JoyfillModel"]
        ),
        .testTarget(
            name: "JoyfillFormulasTests",
            dependencies: ["JoyfillFormulas", "JoyfillModel"]
        ),
        .testTarget(
            name: "JoyfillAPIServiceTests",
            dependencies: ["JoyfillAPIService", "JoyfillModel"]
        ),
    ]
)
