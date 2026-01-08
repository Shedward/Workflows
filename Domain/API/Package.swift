// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "API",
    platforms: [.macOS(.v26)],
    products: [
        .library(
            name: "API",
            targets: ["API"]
        ),
    ],
    dependencies: [
        .package(path: "../Core/Core"),
        .package(path: "../Core/RestClient")
    ],
    targets: [
        .target(
            name: "API",
            dependencies: [
                .product(name: "Core", package: "Core"),
                .product(name: "RestClient", package: "RestClient")
            ]
        ),

    ]
)
