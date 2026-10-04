//
//  WorkflowError+HTTPResponseError.swift
//  WorkflowServer
//
//  Created by Vlad Maltsev on 23.02.2026.
//

import Hummingbird
import WorkflowEngine

extension WorkflowsError.WorkflowNotFound: @retroactive HTTPResponseError, APIError {
    public var status: HTTPResponse.Status {
        .notFound
    }

    public var userDescription: String {
        "Workflow not found"
    }
}

extension WorkflowsError.WorkflowInstanceNotFound: @retroactive HTTPResponseError, APIError {
    public var status: HTTPResponse.Status {
        .notFound
    }

    public var userDescription: String {
        "Workflow instance not found"
    }
}

extension WorkflowsError.TransitionProcessNotFoundForInstance: @retroactive HTTPResponseError, APIError {
    public var status: HTTPResponse.Status {
        .internalServerError
    }

    public var userDescription: String {
        "Transition process not found for instance"
    }
}

extension WorkflowsError.InvalidRouteTarget: @retroactive HTTPResponseError, APIError {
    public var status: HTTPResponse.Status {
        .internalServerError
    }

    public var userDescription: String {
        "Transition routed to an undeclared target state"
    }
}

extension WorkflowsError.InstanceNotAsking: @retroactive HTTPResponseError, APIError {
    public var status: HTTPResponse.Status {
        .conflict
    }

    public var userDescription: String {
        "Workflow instance is not waiting for an answer"
    }
}
