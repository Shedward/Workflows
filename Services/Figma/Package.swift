// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Figma",
    platforms: [.macOS(.v13)],
    products: [
        .library(
            name: "Figma",
            targets: ["Figma"]
        ),
    ],
    dependencies: [
        .package(path: "../Core/RestClient"),
        .package(path: "../Core/TestsPrelude")
    ],
    targets: [
        .target(
            name: "Figma",
            dependencies: ["RestClient"]
        ),
        .testTarget(
            name: "FigmaTests",
            dependencies: ["Figma", "TestsPrelude"]
        ),
    ]
)
