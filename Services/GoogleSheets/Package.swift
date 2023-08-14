// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GoogleSheets",
    platforms: [.macOS(.v13)],
    products: [
        .library(
            name: "GoogleSheets",
            targets: ["GoogleSheets"]
        ),
    ],
    dependencies: [
        .package(path: "../Core/RestClient")
    ],
    targets: [
        .target(
            name: "GoogleSheets",
            dependencies: ["RestClient"]
        ),
        .testTarget(
            name: "GoogleSheetsTests",
            dependencies: ["GoogleSheets"]
        ),
    ]
)
