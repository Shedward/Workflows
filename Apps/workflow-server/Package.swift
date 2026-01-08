// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "WorkflowServer",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "WorkflowServer",
            targets: ["WorkflowServer"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-configuration.git", from: "1.0.0", traits: ["CommandLineArguments"])
    ],
    targets: [
        .target(
            name: "WorkflowServer",
            dependencies: [
                .product(name: "Hummingbird", package: "hummingbird"),
                .product(name: "Configuration", package: "swift-configuration")
            ]
        )
    ]
)
