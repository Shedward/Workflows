// swift-tools-version: 6.2

import PackageDescription
import CompilerPluginSupport

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
        .package(path: "../Core/Core"),
        .package(path: "../Domain/API"),
        .package(url: "https://github.com/apple/swift-syntax", from: "602.0.0")
    ],
    targets: [
        .target(
            name: "WorkflowEngine",
            dependencies: [
                .product(name: "Core", package: "Core"),
                .product(name: "API", package: "API"),
                "WorkflowMacro"
            ]
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
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftLexicalLookup", package: "swift-syntax")
            ]
        )
    ]
)
