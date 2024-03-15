// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JoyfillAPIService",
    products: [
        .library(
            name: "JoyfillAPIService",
            targets: ["JoyfillAPIService"]),
    ],
    dependencies: [
        .package(url: "https://github.com/joyfill/components-swift-models", branch: "main"),
    ],
    targets: [
        .target(
            name: "JoyfillAPIService",
            dependencies: [
                "components-swift-models"
            ]
        ),
        .testTarget(
            name: "JoyfillAPIServiceTests",
            dependencies: ["JoyfillAPIService"]),
    ]
)