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
    targets: [
        .target(
            name: "WorkflowApp"
        ),
    ]
)
