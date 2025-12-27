// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "RestClient",
    platforms: [.macOS(.v26)],
    products: [
        .library(
            name: "RestClient",
            targets: ["RestClient"]
        ),
    ],
    dependencies: [
        .package(path: "../Core")
    ],
    targets: [
        .target(
            name: "RestClient",
            dependencies: [
                .product(name: "Core", package: "Core")
            ]
        ),
    ]
)
