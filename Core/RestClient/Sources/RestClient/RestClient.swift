//
//  RestClient.swift
//
//
//  Created by v.maltsev on 23.09.2023.
//

public protocol RestClient {
    func request<Request, Response>(_ request: RestRequest<Request, Response>) async throws -> Response
}
