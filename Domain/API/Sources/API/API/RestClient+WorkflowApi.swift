//
//  RestClient+WorkflowApi.swift
//  API
//

import Foundation
import Rest

extension RestClient {
    /// Takes precedence over Rest's `fetch(_ api:)` for workflow endpoints: a refused response whose
    /// body is the server's error description surfaces as a `ServerError`, so the caller can show the
    /// server's explanation instead of the status code.
    public func fetch<A: WorkflowApi>(_ api: A) async throws -> A.ResponseBody {
        do {
            return try await fetch(api.request)
        } catch let rejected as ResponseRejected {
            guard let description = try? JSONDecoder().decode(ErrorDescription.self, from: rejected.body) else {
                throw rejected
            }
            throw ServerError(status: rejected.statusCode, description: description)
        }
    }
}
