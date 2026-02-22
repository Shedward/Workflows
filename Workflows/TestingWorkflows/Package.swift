// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "TestingWorkflows",
    platforms: [.macOS(.v26)],
    products: [
        .library(
            name: "TestingWorkflows",
            targets: ["TestingWorkflows"]
        )
    ],
    dependencies: [
        .package(path: "../Core/Core"),
        .package(path: "../Domain/WorkflowEngine")
    ],
    targets: [
        .target(
            name: "TestingWorkflows",
            dependencies: [
                .product(name: "Core", package: "Core"),
                .product(name: "WorkflowEngine", package: "WorkflowEngine")
            ]
        )
    ]
)
