//
//  RestClient.swift
//  Created by Vladislav Maltsev on 16.07.2023.
//

import Foundation
import Prelude

public actor RestClient {
    private let endpoint: RestEndpoint
    private let session: URLSession

    public var requestDecorators: [RequestDecorator] = []
    public var responseValidator: [ResponseValidator] = [ResponseCodeValidator()]

    public init(endpoint: RestEndpoint, session: URLSession = .shared) {
        self.endpoint = endpoint
        self.session = session
    }

    @discardableResult
    public func request<Request, Response>(_ request: RestRequest<Request, Response>) async throws -> Response {
        let restRequest = try await Failure.wrap("Decorating request") {
            var request = request
            for decorator in requestDecorators {
                request = try await decorator.request(from: request)
            }
            return request
        }

        let urlRequest = try Failure.wrap("Composing request \(Request.self)") {
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

        let (data, response) = try await Failure.wrap("Requesting data") {
            try await session.data(for: urlRequest)
        }

        try Failure.wrap("Validating response") {
            for validator in responseValidator {
                try validator.validate(response)
            }
        }

        let responseBody = try Failure.wrap("Parsing response") {
            try Response.fromData(data)
        }

        return responseBody
    }
}
