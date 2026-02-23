//
//  WorkflowError+HTTPResponseError.swift
//  WorkflowServer
//
//  Created by Vlad Maltsev on 23.02.2026.
//

import Hummingbird
import WorkflowEngine

extension WorkflowsError.WorkflowNotFound: @retroactive ResponseGenerator {
    public func response(from request: Request, context: some RequestContext) throws -> Response {
        try ErrorResponse(
            status: status,
            userDescription: "Workflow not found",
            debugDescription: String(describing: self)
        )
        .response(from: request, context: context)
    }
}

extension WorkflowsError.WorkflowNotFound: @retroactive HTTPResponseError {
    public var status: HTTPResponse.Status {
        .notFound
    }
}

extension WorkflowsError.WorkflowInstanceNotFound: @retroactive ResponseGenerator {
    public func response(from request: Request, context: some RequestContext) throws -> Response {
        try ErrorResponse(
            status: status,
            userDescription: "Workflow instance not found",
            debugDescription: String(describing: self)
        )
        .response(from: request, context: context)
    }
}

extension WorkflowsError.WorkflowInstanceNotFound: @retroactive HTTPResponseError {
    public var status: HTTPResponse.Status {
        .notFound
    }
}

extension WorkflowsError.WorkflowInstanceMismatch: @retroactive ResponseGenerator {
    public func response(from request: Request, context: some RequestContext) throws -> Response {
        try ErrorResponse(
            status: status,
            userDescription: "Workflow instance does not match expected workflow",
            debugDescription: String(describing: self)
        )
        .response(from: request, context: context)
    }
}

extension WorkflowsError.WorkflowInstanceMismatch: @retroactive HTTPResponseError {
    public var status: HTTPResponse.Status {
        .internalServerError
    }
}

extension WorkflowsError.TransitionNotFound: @retroactive ResponseGenerator {
    public func response(from request: Request, context: some RequestContext) throws -> Response {
        try ErrorResponse(
            status: status,
            userDescription: "Transition not found",
            debugDescription: String(describing: self)
        )
        .response(from: request, context: context)
    }
}

extension WorkflowsError.TransitionNotFound: @retroactive HTTPResponseError {
    public var status: HTTPResponse.Status {
        .notFound
    }
}

extension WorkflowsError.TransitionProcessNotFoundForInstance: @retroactive ResponseGenerator {
    public func response(from request: Request, context: some RequestContext) throws -> Response {
        try ErrorResponse(
            status: status,
            userDescription: "Transition process not found for instance",
            debugDescription: String(describing: self)
        )
        .response(from: request, context: context)
    }
}

extension WorkflowsError.TransitionProcessNotFoundForInstance: @retroactive HTTPResponseError {
    public var status: HTTPResponse.Status {
        .internalServerError
    }
}
