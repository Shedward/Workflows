//
//  RestClient.swift
//  Created by Vladislav Maltsev on 16.07.2023.
//

import Foundation
import os
import Prelude

public actor RestClient {
    private let endpoint: RestEndpoint
    private let session: URLSession
    private let logger = Logger(scope: .network)

    public var requestDecorators: [RequestDecorator]
    public var responseValidator: [ResponseValidator]

    public init(
        endpoint: RestEndpoint,
        session: URLSession = .shared,
        requestDecorators: [RequestDecorator] = [],
        responseValidators: [ResponseValidator] = [ResponseCodeValidator()]
    ) {
        self.endpoint = endpoint
        self.session = session
        self.requestDecorators = requestDecorators
        self.responseValidator = responseValidators
    }

    @discardableResult
    public func request<Request, Response>(_ request: RestRequest<Request, Response>) async throws -> Response {
        logger.trace("→ Begin \(request.shortDescription, privacy: .public)")
        var responseData: Data?
        do {
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
            responseData = data

            try Failure.wrap("Validating response") {
                for validator in responseValidator {
                    try validator.validate(response)
                }
            }
            
            let responseBody = try Failure.wrap("Parsing response") {
                try Response.fromData(data)
            }
            
            logger.trace("""
            ← Finished \(restRequest, privacy: .public)

            \(self.responseDescription(response, responseBody: responseBody), privacy: .public)
            """)

            return responseBody
        } catch {
            logger.error("""
            ← Failed \(request.shortDescription, privacy: .public)

            Error:
            \(error, privacy: .public)
            Response:
            \(responseData.flatMap { String(data: $0, encoding: .utf8) } ?? "<no response>", privacy: .public)
            """)
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
