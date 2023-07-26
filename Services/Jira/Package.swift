// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Jira",
    platforms: [.macOS(.v13)],
    products: [
        .library(
            name: "Jira",
            targets: ["Jira"]
        ),
    ],
    dependencies: [
        .package(path: "../Core/Prelude"),
        .package(path: "../Core/RestClient")
    ],
    targets: [
        .target(
            name: "Jira",
            dependencies: ["Prelude", "RestClient"]
        ),
        .testTarget(
            name: "JiraTests",
            dependencies: ["Jira"]
        ),
    ]
)
