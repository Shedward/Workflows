// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Prelude",
    platforms: [.macOS(.v13)],
    products: [
        .library(
            name: "Prelude",
            targets: ["Prelude"]),
    ],
    targets: [
        .target(
            name: "Prelude"),
        .testTarget(
            name: "PreludeTests",
            dependencies: ["Prelude"]),
    ]
)
