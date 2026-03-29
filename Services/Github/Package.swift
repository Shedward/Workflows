// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Github",
    platforms: [.macOS(.v26)],
    products: [
        .library(
            name: "Github",
            targets: ["Github"]
        )
    ],
    dependencies: [
        .package(path: "../Core/Rest")
    ],
    targets: [
        .target(
            name: "Github",
            dependencies: [
                .product(name: "Rest", package: "Rest")
            ]
        )

    ]
)
