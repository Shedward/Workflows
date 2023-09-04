// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WorkflowsApp",
    platforms: [.macOS(.v13)],
    products: [
        .library(
            name: "WorkflowsApp",
            targets: ["WorkflowsApp"]
        ),
    ],
    dependencies: [
        .package(path: "../Workflows/HeadHunter")
    ],
    targets: [
        .target(
            name: "WorkflowsApp",
            dependencies: [
                "HeadHunter"
            ]
        )
    ]
)
