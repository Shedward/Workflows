//
//  NetworkRestClient.swift
//  Rest
//
//  Created by Vlad Maltsev on 21.12.2025.
//

import Core
import Foundation
import os

public actor NetworkRestClient: RestClient {
    private let endpoint: Endpoint
    private let session: URLSession
    private let logger = Logger(scope: .network)
    private let requestDecorators: RequestDecoratorsSet
    private let responseValidators: URLResponseValidatorsSet

    public init(
        endpoint: Endpoint,
        session: URLSession = .shared,
        requestDecorators: RequestDecoratorsSet = .init(),
        responseValidators: URLResponseValidatorsSet = .init()
            .validateStatusCode()
    ) {
        self.endpoint = endpoint
        self.session = session
        self.requestDecorators = requestDecorators
        self.responseValidators = responseValidators
    }

    public func fetch<RequestBody, ResponseBody>(_ request: Request<RequestBody, ResponseBody>) async throws -> ResponseBody where RequestBody : DataEncodable, ResponseBody : DataDecodable {

        logger?.trace("→ Begin \(request.shortDescription, privacy: .public)")

        var responseData: Data?
        do {
            let decoratedRequest = try await Failure.wrap("Decorating request") {
                try await requestDecorators.decorate(request)
            }

            let urlRequest = try Failure.wrap("Composing request \(RequestBody.self)") {
                var url = endpoint.host

                if let path = decoratedRequest.path {
                    url.append(path: path)
                }

                let queryItems = request.query.values
                    .map { URLQueryItem(name: $0.key, value: $0.value.queryValue) }
                    .filter { $0.value != nil }
                url.append(queryItems: queryItems)

                var urlRequest = URLRequest(url: url)
                urlRequest.httpMethod = request.method.rawValue
                urlRequest.allHTTPHeaderFields = decoratedRequest.headers.values
                urlRequest.httpBody = try request.body.data()
                return urlRequest
            }

            let (data, response) = try await Failure.wrap("Executing request") {
                try await session.data(for: urlRequest)
            }
            responseData = data

            try Failure.wrap("Validating response") {
                try responseValidators.validate(response)
            }

            let responseBody = try Failure.wrap("Parsing response") {
                try ResponseBody(data: data)
            }

            logger?.trace(
                """
                ← Finished \(request, privacy: .public)

                \(self.responseDescription(response, responseBody: responseBody), privacy: .public)
                """
            )

            return responseBody
        } catch {
            logger?.error(
                """
                ← Failed \(request.shortDescription, privacy: .public)

                Error:
                \(error, privacy: .public)
                Response:
                \(responseData.flatMap { String(data: $0, encoding: .utf8) } ?? "<no response>", privacy: .public)
                """
            )
            throw error
        }
    }

    private func responseDescription<Response>(_ urlResponse: URLResponse, responseBody: Response) -> String {
        guard let urlResponse = urlResponse as? HTTPURLResponse else { return "Response: -" }

        return """
            Response:
              Status Code: \(urlResponse.statusCode)
              URL: \(urlResponse.url?.absoluteString ?? "-")
              Body: \(responseBody)
            """
    }
}

extension NetworkRestClient {
    public struct Endpoint: Sendable {
        public let host: URL

        public init(host: URL) {
            self.host = host
        }
    }
}
