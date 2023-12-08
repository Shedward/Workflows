// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HeadHunter",
    platforms: [.macOS(.v13)],
    products: [
        .library(
            name: "HeadHunter",
            targets: ["HeadHunter"]
        ),
    ],
    dependencies: [
        .package(path: "../Core/Prelude"),
        .package(path: "../Core/TestsPrelude"),
        .package(path: "../System/LocalStorage"),
        .package(path: "../System/SecureStorage"),
        .package(path: "../System/Git"),
        .package(path: "../Services/GoogleCloud"),
        .package(path: "../Services/Jira"),
        .package(path: "../Workflows/Workflow")
    ],
    targets: [
        .target(
            name: "HeadHunter",
            dependencies: [
                "Prelude",
                "LocalStorage",
                "SecureStorage",
                "Git",
                "GoogleCloud",
                "Jira",
                "Workflow"
            ]
        ),
        .testTarget(
            name: "HeadHunterTests",
            dependencies: [
                "HeadHunter",
                "TestsPrelude"
            ]
        )
    ]
)
