// swift-tools-version:5.9

import PackageDescription

let package = Package(
  name: "JSONSchema",
  platforms: [
    .iOS(.v15),
    .macOS(.v10_15),
  ],
  products: [
    .library(name: "JSONSchema", targets: ["JSONSchema"]),
  ],
  dependencies: [],
  targets: [
    .target(name: "JSONSchema", dependencies: [], path: "Sources"),
  ]
)
