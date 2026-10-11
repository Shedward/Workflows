//
//  Transition+Mocks.swift
//  WorkflowApp
//

import API

extension API.Transition {
    enum Mock {
        static func simple(processId: String) -> API.Transition {
            API.Transition(processId: processId, fromState: "working", targets: ["next"], trigger: "manual")
        }
    }
}
