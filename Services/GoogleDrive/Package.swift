// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GoogleDrive",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "GoogleDrive",
            targets: ["GoogleDrive"]
        ),
    ],
    dependencies: [
        .package(path: "../Core/RestClient")
    ],
    targets: [
        .target(
            name: "GoogleDrive",
            dependencies: ["RestClient"]
        )
    ]
)
