// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UI",
    platforms: [.macOS(.v13)],
    products: [
        .library(
            name: "UI",
            targets: ["UI"]
        ),
    ],
    targets: [
        .target(
            name: "UI"
        )
    ]
)
