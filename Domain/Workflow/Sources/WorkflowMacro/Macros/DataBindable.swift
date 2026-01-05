//
//  Workflow.swift
//  Workflow
//
//  Created by Vlad Maltsev on 02.01.2026.
//

@attached(
    member,
    names: named(bind)
)
public macro DataBindable() =
    #externalMacro(
        module: "WorkflowMacroImpl",
        type: "DataBindableMacro"
    )
