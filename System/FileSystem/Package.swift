// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FileSystem",
    platforms: [.macOS(.v13)],
    products: [
        .library(
            name: "FileSystem",
            targets: ["FileSystem"]
        ),
    ],
    dependencies: [
        .package(path: "../Core/TestsPrelude")
    ],
    targets: [
        .target(
            name: "FileSystem"
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
