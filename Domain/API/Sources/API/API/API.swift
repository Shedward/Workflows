//
//  AP.swift
//  API
//
//  Created by Vlad Maltsev on 08.01.2026.
//

import Core
import RestClient

public protocol WorkflowApi: Api, Sendable {
    static var method: Method { get }
    static var path: String { get }
}

public extension WorkflowApi where RequestBody: Defaultable  {
    func request(_ pathElements: PathElements = .init()) ->  Request<RequestBody, ResponseBody> {
        Request(method: Self.method, path: pathElements.apply(to: Self.path), body: .init())
    }

    var request: Request<RequestBody, ResponseBody> {
        request()
    }
}

public extension WorkflowApi {
    func request(_ pathElements: PathElements = .init(), body: RequestBody) -> Request<RequestBody, ResponseBody> {
        Request(method: Self.method, path: pathElements.apply(to: Self.path), body: body)
    }
}
