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
        .package(url: "https://github.com/joyfill/JoyfillModel", exact: "2.0.5"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Joyfill",
            dependencies: [
                "JoyfillModel",
            ]
        ),
        .testTarget(
            name: "JoyfillTests",
            dependencies: ["Joyfill"]),
    ]
)
