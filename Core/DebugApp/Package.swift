// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DebugApp",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(path: "../Core/RestClient")
    ],
    targets: [
        .executableTarget(
            name: "DebugApp",
            dependencies: ["RestClient"]
        ),
    ]
)
