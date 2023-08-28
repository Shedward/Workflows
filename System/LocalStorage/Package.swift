// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LocalStorage",
    platforms: [.macOS(.v13)],
    products: [
        .library(
            name: "LocalStorage",
            targets: ["LocalStorage"]
        ),
    ],
    dependencies: [
        .package(path: "../Core/Prelude")
    ],
    targets: [
        .target(
            name: "LocalStorage",
            dependencies: ["Prelude"]
        ),
        .testTarget(
            name: "LocalStorageTests",
            dependencies: ["LocalStorage"]
        ),
    ]
)
