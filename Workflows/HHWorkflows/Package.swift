// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "HHWorkflows",
    platforms: [.macOS(.v26)],
    products: [
        .library(
            name: "HHWorkflows",
            targets: ["HHWorkflows"]
        ),
    ],
    dependencies: [
        .package(path: "../Core/Core"),
        .package(path: "../Services/Git"),
        .package(path: "../Domain/WorkflowEngine")
    ],
    targets: [
        .target(
            name: "HHWorkflows",
            dependencies: [
                .product(name: "Core", package: "Core"),
                .product(name: "Git", package: "Git"),
                .product(name: "WorkflowEngine", package: "WorkflowEngine")
            ]
        ),
    ]
)
