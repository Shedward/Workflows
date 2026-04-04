// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "WorkflowApp",
    platforms: [
        .macOS(.v26)
    ],
    products: [
        .library(
            name: "WorkflowApp",
            targets: ["WorkflowApp"]
        ),
    ],
    dependencies: [
        .package(path: "../Core/Rest"),
        .package(path: "../Domain/API"),
    ],
    targets: [
        .target(
            name: "WorkflowApp",
            dependencies: [
                .product(name: "Rest", package: "Rest"),
                .product(name: "API", package: "API")
            ]
        ),
    ]
)
