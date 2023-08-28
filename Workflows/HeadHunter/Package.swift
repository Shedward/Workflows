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
        .package(path: "../System/LocalStorage"),
        .package(path: "../System/SecureStorage"),
        .package(path: "../Services/GoogleCloud"),
    ],
    targets: [
        .target(
            name: "HeadHunter",
            dependencies: [
                "Prelude",
                "LocalStorage",
                "SecureStorage",
                "GoogleCloud"
            ]
        )
    ]
)