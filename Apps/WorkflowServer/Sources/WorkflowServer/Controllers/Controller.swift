//
//  Controller.swift
//  WorkflowServer
//
//  Created by Vlad Maltsev on 20.02.2026.
//

import Hummingbird

protocol Controller: Sendable {
    var endpoints: RouteCollection<AppRequestContext> { get }
}

extension Controller {
    typealias Context = AppRequestContext
}
