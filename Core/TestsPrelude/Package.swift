// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TestsPrelude",
    platforms: [.macOS(.v13)],
    products: [
        .library(
            name: "TestsPrelude",
            targets: ["TestsPrelude"]
        ),
    ],
    dependencies: [
        .package(path: "../Core/Prelude")
    ],
    targets: [
        .target(
            name: "TestsPrelude",
            dependencies: ["Prelude"]
        )
    ]
)
