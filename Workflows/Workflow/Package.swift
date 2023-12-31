// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Workflow",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "Workflow",
            targets: ["Workflow"]
        ),
    ],
    dependencies: [
        .package(path: "../System/LocalStorage")
    ],
    targets: [
        .target(
            name: "Workflow",
            dependencies: [
                "LocalStorage"
            ]
        ),
        .testTarget(
            name: "WorkflowTests",
            dependencies: ["Workflow"]
        ),
    ]
)
