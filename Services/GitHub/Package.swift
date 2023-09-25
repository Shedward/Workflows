// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GitHub",
    platforms: [.macOS(.v13)],
    products: [
        .library(
            name: "GitHub",
            targets: ["GitHub"]
        ),
    ],
    dependencies: [
        .package(path: "../Core/RestClient"),
        .package(path: "../Core/TestsPrelude")
    ],
    targets: [
        .target(
            name: "GitHub",
            dependencies: ["RestClient"]
        ),
        .testTarget(
            name: "GitHubTests",
            dependencies: ["GitHub", "TestsPrelude"]
        ),
    ]
)
