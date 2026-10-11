//
//  ErrorDescription+API.swift
//  WorkflowServer
//

import API
import Core

extension ErrorDescription {
    init(model error: any Error) {
        self.init(
            userDescription: (error as? DescriptiveError)?.userDescription ?? error.localizedDescription,
            debugDescription: String(describing: error)
        )
    }
}
