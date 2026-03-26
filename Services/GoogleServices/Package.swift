// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "GoogleServices",
    platforms: [.macOS(.v26)],
    products: [
        .library(
            name: "GoogleServices",
            targets: ["GoogleServices"]
        ),
    ],
    dependencies: [
        .package(path: "../Core/Core"),
        .package(path: "../Core/Rest"),
    ],
    targets: [
        .target(
            name: "GoogleServices",
            dependencies: [
                .product(name: "Core", package: "Core"),
                .product(name: "Rest", package: "Rest"),
            ]
        ),
    ]
)
