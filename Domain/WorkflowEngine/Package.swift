// swift-tools-version: 6.2

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "WorkflowEngine",
    platforms: [.macOS(.v26)],
    products: [
        .library(
            name: "WorkflowEngine",
            targets: ["WorkflowEngine"]
        )
    ],
    dependencies: [
        .package(path: "../../Core/Core"),
        .package(url: "https://github.com/apple/swift-syntax", from: "604.0.0")
    ],
    targets: [
        .target(
            name: "WorkflowEngine",
            dependencies: [
                .product(name: "Core", package: "Core"),
                "WorkflowMacro"
            ]
        ),
        .testTarget(
            name: "WorkflowEngineTests",
            dependencies: ["WorkflowEngine"]
        ),
        .target(
            name: "WorkflowMacro",
            dependencies: ["WorkflowMacroImpl"]
        ),
        .macro(
            name: "WorkflowMacroImpl",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        )
    ]
)
