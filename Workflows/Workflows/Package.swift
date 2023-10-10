// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Workflows",
    platforms: [.macOS(.v13)],
    products: [
        .library(
            name: "Workflows",
            targets: ["Workflows"]
        ),
    ],
    dependencies: [
        .package(path: "../System/LocalStorage")
    ],
    targets: [
        .target(
            name: "Workflows",
            dependencies: [
                "LocalStorage"
            ]
        ),
        .testTarget(
            name: "WorkflowsTests",
            dependencies: ["Workflows"]
        ),
    ]
)
