//
//  Controller.swift
//  WorkflowServer
//
//  Created by Vlad Maltsev on 20.02.2026.
//

import Hummingbird

public protocol Controller: Sendable {
    var endpoints: RouteCollection<AppRequestContext> { get }
}

public extension Controller {
    typealias Context = AppRequestContext
}
