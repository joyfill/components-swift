// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JoyfillModel",
    products: [
        .library(
            name: "JoyfillModel",
            targets: ["JoyfillModel"]),
    ],
    dependencies: [
        // Add your dependencies here, if any.
    ],
    targets: [
        .target(
            name: "JoyfillModel",
            dependencies: [
                // Add your target dependencies here, if any.
            ]
        ),
        .testTarget(
            name: "JoyfillModelTests",
            dependencies: ["JoyfillModel"]),
    ]
)