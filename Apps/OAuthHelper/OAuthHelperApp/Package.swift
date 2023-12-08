// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OAuthHelperApp",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "OAuthHelperApp",
            targets: ["OAuthHelperApp"]
        ),
    ],
    dependencies: [
        .package(path: "../Core/Prelude"),
        .package(path: "../Core/RestClient"),
        .package(path: "../System/SecureStorage"),
        .package(path: "../System/LocalStorage"),
        .package(path: "../Services/GoogleCloud")
    ],
    targets: [
        .target(
            name: "OAuthHelperApp",
            dependencies: [
                "Prelude",
                "RestClient",
                "SecureStorage",
                "GoogleCloud",
                "LocalStorage"
            ],
            resources: [
                .process("Resources/Assets.xcassets")
            ]
        )
    ]
)
