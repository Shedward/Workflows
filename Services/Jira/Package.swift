// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Jira",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "Jira",
            targets: ["Jira"]
        ),
    ],
    dependencies: [
        .package(path: "../Core/Prelude"),
        .package(path: "../Core/TestsPrelude"),
        .package(path: "../Core/RestClient"),
        .package(path: "../System/SecureStorage"),
    ],
    targets: [
        .target(
            name: "Jira",
            dependencies: ["Prelude", "RestClient", "SecureStorage"]
        ),
        .testTarget(
            name: "JiraTests",
            dependencies: ["Jira", "TestsPrelude"]
        ),
    ]
)
