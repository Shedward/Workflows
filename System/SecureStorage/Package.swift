// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SecureStorage",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "SecureStorage",
            targets: ["SecureStorage"]
        ),
    ],
    dependencies: [
        .package(path: "../Core/Prelude")
    ],
    targets: [
        .target(
            name: "SecureStorage",
            dependencies: ["Prelude"]
        ),
        .testTarget(
            name: "SecureStorageTests",
            dependencies: ["SecureStorage"]
        ),
    ]
)
