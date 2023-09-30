// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Git",
    platforms: [.macOS(.v13)],
    products: [
        .library(
            name: "Git",
            targets: ["Git"]
        ),
    ],
    dependencies: [
        .package(path: "../System/Executable"),
        .package(path: "../Core/TestsPrelude")
    ],
    targets: [
        .target(
            name: "Git",
            dependencies: ["Executable"]
        ),
        .testTarget(
            name: "GitTests",
            dependencies: ["Git", "TestsPrelude"]
        ),
    ]
)
