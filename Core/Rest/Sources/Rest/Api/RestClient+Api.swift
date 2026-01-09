//
//  RestClient+Api.swift
//  Rest
//
//  Created by Vlad Maltsev on 23.12.2025.
//

extension RestClient {
    public func fetch<A: Api>(
        _ api: A
    ) async throws -> A.ResponseBody {
        try await fetch(api.request)
    }
}
