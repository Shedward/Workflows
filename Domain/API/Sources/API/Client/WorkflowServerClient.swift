//
//  WorkflowServerClient.swift
//  API
//

import Foundation
import Rest

/// A `RestClient` for the workflow server: a refused response whose body is the server's error
/// description surfaces as a `ServerError`, so the caller can show the server's explanation.
public struct WorkflowServerClient: RestClient {
    let base: any RestClient

    public init(_ base: any RestClient) {
        self.base = base
    }

    public init(endpoint: NetworkRestClient.Endpoint) {
        self.init(NetworkRestClient(endpoint: endpoint))
    }

    public func fetch<RequestBody, ResponseBody>(
        _ request: Request<RequestBody, ResponseBody>
    ) async throws -> ResponseBody {
        do {
            return try await base.fetch(request)
        } catch let rejected as ResponseRejected {
            guard let description = try? JSONDecoder().decode(ErrorDescription.self, from: rejected.body) else {
                throw rejected
            }
            throw ServerError(status: rejected.statusCode, description: description)
        }
    }
}
