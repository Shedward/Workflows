// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Executable",
    platforms: [.macOS(.v13)],
    products: [
        .library(
            name: "Executable",
            targets: ["Executable"]
        ),
    ],
    dependencies: [
        .package(path: "../Core/Prelude")
    ],
    targets: [
        .target(
            name: "Executable",
            dependencies: ["Prelude"]
        ),
        .testTarget(
            name: "ExecutableTests",
            dependencies: ["Executable"]
        ),
    ]
)
