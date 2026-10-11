//
//  TransitionTrigger+API.swift
//  WorkflowServer
//

import WorkflowEngine

extension TransitionTrigger {
    /// The wire string is part of the REST contract; renaming an engine case must not change it.
    var apiValue: String {
        switch self {
            case .manual:
                "manual"
            case .automatic:
                "automatic"
        }
    }
}
