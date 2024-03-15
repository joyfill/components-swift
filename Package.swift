// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Joyfill",
    platforms: [
        .iOS(.v15) // Set the minimum deployment target to iOS 15
    ], products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Joyfill",
            targets: ["Joyfill"]),
    ],
    dependencies: [
        .package(url: "https://github.com/joyfill/components-swift-models", branch: "main"),
        .package(url: "https://github.com/joyfill/components-swift-apiservice", branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Joyfill",
            dependencies: [
                "components-swift-models",
                "components-swift-apiservice"
            ]
        ),
        .testTarget(
            name: "JoyfillTests",
            dependencies: ["Joyfill"]),
    ]
)
