// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FileSystem",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "FileSystem",
            targets: ["FileSystem"]
        ),
    ],
    dependencies: [
        .package(path: "../Core/TestsPrelude"),
        .package(path: "../Core/Prelude")
    ],
    targets: [
        .target(
            name: "FileSystem",
            dependencies: [
                "Prelude"
            ]
        ),
        .testTarget(
            name: "FileSystemTests",
            dependencies: [
                "FileSystem",
                "TestsPrelude"
            ]
        ),
    ]
)
