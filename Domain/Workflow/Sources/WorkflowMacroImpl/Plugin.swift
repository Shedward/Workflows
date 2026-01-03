//
//  main.swift
//  Workflow
//
//  Created by Vlad Maltsev on 02.01.2026.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct WorkflowMacrosPlugin: CompilerPlugin {
    let providingMacros: [any Macro.Type] = [
        InputMacro.self
    ]
}
