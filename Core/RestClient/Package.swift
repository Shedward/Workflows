// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RestClient",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "RestClient",
            targets: ["RestClient"]
        ),
    ],
    dependencies: [
        .package(path: "../Core/Prelude")
    ],
    targets: [
        .target(
            name: "RestClient",
            dependencies: ["Prelude"]
        ),
        .testTarget(
            name: "RestClientTests",
            dependencies: ["RestClient"]
        ),
    ]
)
