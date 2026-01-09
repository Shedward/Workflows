// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Rest",
    platforms: [.macOS(.v26)],
    products: [
        .library(
            name: "Rest",
            targets: ["Rest"]
        ),
    ],
    dependencies: [
        .package(path: "../Core")
    ],
    targets: [
        .target(
            name: "Rest",
            dependencies: [
                .product(name: "Core", package: "Core")
            ]
        ),
    ]
)
