//
//  API+Route.swift
//  WorkflowServer
//
//  Created by Vlad Maltsev on 08.01.2026.
//

import API
import Foundation
import Hummingbird
import Rest

extension Parameters {
    /// Path parameters arrive percent-encoded; every production workflow id is Cyrillic.
    func requireDecoded(_ name: String) throws -> String {
        let raw = try require(name)
        guard let decoded = raw.removingPercentEncoding else {
            throw HTTPError(.badRequest, message: "Parameter '\(name)' is not valid percent-encoding: \(raw)")
        }
        return decoded
    }
}

extension RouteCollection where Context == AppRequestContext {
    @discardableResult
    public func on<Api: WorkflowApi>(
        _ api: Api.Type,
        use closure: @Sendable @escaping (Request, Api.RequestBody, Context) async throws -> some ResponseGenerator
    ) -> Self
    where Api.RequestBody: DataDecodable {
        let responder = CallbackResponder<Context> { request, context in
            let bytesBuffer = try await request.body.collect(upTo: context.maxUploadSize)
            let data = Data(buffer: bytesBuffer)
            let body: Api.RequestBody
            do {
                body = try Api.RequestBody(data: data)
            } catch {
                throw InvalidRequestBody(expected: String(describing: Api.RequestBody.self), underlying: error)
            }
            let output = try await closure(request, body, context)
            return try output.response(from: request, context: context)
        }
        return on(.init(Api.path), method: Api.method.httpRequestMethod, responder: responder)
    }

    @discardableResult
    public func on<Api: WorkflowApi>(
        _ api: Api.Type,
        use closure: @Sendable @escaping (Request, Api.RequestBody, Context) async throws -> Api.ResponseBody
    ) -> Self
    where Api.RequestBody: DataDecodable, Api.ResponseBody: DataEncodable {
        on(Api.self) { request, body, context in
            let responseModel = try await closure(request, body, context)
            return ApiResponse(responseBody: responseModel)
        }
    }
}
