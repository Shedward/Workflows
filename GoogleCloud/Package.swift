// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GoogleCloud",
    platforms: [.macOS(.v13)],
    products: [
        .library(
            name: "GoogleCloud",
            targets: ["GoogleCloud"]
        ),
    ],
    dependencies: [
        .package(path: "../Core/RestClient"),
        .package(path: "../Core/TestsPrelude")
    ],
    targets: [
        .target(
            name: "GoogleCloud",
            dependencies: ["RestClient"]
        ),
        .testTarget(
            name: "GoogleCloudTests",
            dependencies: ["GoogleCloud", "TestsPrelude"]
        ),
    ]
)
