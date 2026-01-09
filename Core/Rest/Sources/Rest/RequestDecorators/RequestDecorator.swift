//
//  RequestDecorator.swift
//  Rest
//
//  Created by Vlad Maltsev on 21.12.2025.
//

public protocol RequestDecorator: Sendable {
    func decorate<RequestBody, ResponseBody>(
        _ request: Request<RequestBody, ResponseBody>
    ) async throws -> Request<RequestBody, ResponseBody>
}
