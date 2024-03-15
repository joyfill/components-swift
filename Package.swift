// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "JoyfillUI",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "JoyfillUI",
            targets: ["JoyfillUI"]),
    ],
    dependencies: [
        .package(path: "./JoyfillAPIService"),
        .package(path: "./JoyfillModel"),
    ],
    targets: [
        .target(
            name: "JoyfillUI",
            dependencies: [
                "JoyfillAPIService",
                "JoyfillModel"
            ]
        ),
        .testTarget(
            name: "JoyfillUITests",
            dependencies: ["JoyfillUI"]),
    ]
)
