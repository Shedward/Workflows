// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UI",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "UI",
            targets: ["UI"]
        ),
    ], 
    dependencies: [
        .package(path: "../Core/Prelude")
    ],
    targets: [
        .target(
            name: "UI",
            dependencies: [
                "Prelude"
            ]
        )
    ]
)
