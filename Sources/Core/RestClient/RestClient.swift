//
//  RestClient.swift
//  Created by Vladislav Maltsev on 16.07.2023.
//

import Foundation

actor RestClient {
    private let endpoint: RestEndpoint
    private let session: URLSession

    init(endpoint: RestEndpoint, session: URLSession = .shared) {
        self.endpoint = endpoint
        self.session = session
    }

    @discardableResult
    func request<Request, Response>(_ request: RestRequest<Request, Response>) async throws -> Response {
        let request = try EError.wrap("Composing request \(Request.self)") {
            try urlRequest(from: request)
        }
        let (data, _) = try await EError.wrap("Requesting data") {
            try await session.data(for: request)
        }
        let responseBody = try EError.wrap("Parsing response") {
            try Response.fromData(data)
        }
        return responseBody
    }

    private func urlRequest<Request, Response>(from restRequest: RestRequest<Request, Response>) throws -> URLRequest {
        var url: URL = endpoint.host
        if let path = restRequest.path {
            url.append(path: path)
        }

        let queryItems = restRequest.query.values.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        url.append(queryItems: queryItems)

        var request = URLRequest(url: url)
        request.httpMethod = restRequest.method.rawValue
        request.allHTTPHeaderFields = restRequest.headers.values

        request.httpBody = try restRequest.body.data()

        return request
    }
}
