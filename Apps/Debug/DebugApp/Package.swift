// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DebugApp",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(path: "../Services/GitHub"),
        .package(path: "../Services/Jira"),
        .package(path: "../Services/Figma"),
        .package(path: "../Services/GoogleCloud"),
        .package(path: "../System/SecureStorage"),
        .package(path: "../System/LocalStorage"),
        .package(path: "../System/Executable"),
        .package(path: "../System/Git"),
        .package(path: "../Workflows/HeadHunter")
    ],
    targets: [
        .executableTarget(
            name: "DebugApp",
            dependencies: [
                "GitHub",
                "Jira",
                "Figma",
                "SecureStorage",
                "LocalStorage",
                "Executable",
                "Git",
                "GoogleCloud",
                "HeadHunter"
            ]
        ),
    ]
)
