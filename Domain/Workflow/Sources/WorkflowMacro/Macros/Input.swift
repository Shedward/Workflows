//
//  Input.swift
//  Workflow
//
//  Created by Vlad Maltsev on 02.01.2026.
//

@attached(peer)
public macro Input(key: String? = nil) =
    #externalMacro(
        module: "WorkflowMacroImpl",
        type: "InputMacro"
    )
