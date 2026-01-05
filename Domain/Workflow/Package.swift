// swift-tools-version: 6.2

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Workflow",
    platforms: [.macOS(.v26)],
    products: [
        .library(
            name: "Workflow",
            targets: ["Workflow"]
        )
    ],
    dependencies: [
        .package(path: "../Core"),
        .package(url: "https://github.com/apple/swift-syntax", from: "602.0.0")
    ],
    targets: [
        .target(
            name: "Workflow",
            dependencies: [
                .product(name: "Core", package: "Core"),
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
