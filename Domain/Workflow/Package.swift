// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Workflow",
    platforms: [.macOS(.v26)],
    products: [
        .library(
            name: "Workflow",
            targets: ["Workflow"]
        ),
    ],
    dependencies: [
        .package(path: "../Core")
    ],
    targets: [
        .target(
            name: "Workflow",
            dependencies: [
                .product(name: "Core", package: "Core")
            ]
        ),

    ]
)
