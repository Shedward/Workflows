// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Git",
    platforms: [.macOS(.v26)],
    products: [
        .library(
            name: "Git",
            targets: ["Git"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-subprocess.git", from: "0.3.0"),
    ],
    targets: [
        .target(
            name: "Git",
            dependencies: [
                .product(name: "Subprocess", package: "swift-subprocess"),
            ]
        )
    ]
)
