// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Joyfill",
    platforms: [
        .iOS(.v15) // Set the minimum deployment target to iOS 15
    ],
    products: [
        .library(
            name: "Joyfill",
            targets: ["Joyfill"]),
    ],
    dependencies: [
        .package(url: "https://github.com/joyfill/JoyfillModel", branch: "collection-development"),
        .package(url: "https://github.com/kylef/JSONSchema.swift", .upToNextMajor(from: "0.6.0")),
    ],
    targets: [
        .target(
            name: "Joyfill",
            dependencies: [
                .product(name: "JSONSchema", package: "JSONSchema.swift"),
                "JoyfillModel",
            ]
        ),
        .testTarget(
            name: "JoyfillTests",
            dependencies: ["Joyfill"]
        ),
    ]
)
