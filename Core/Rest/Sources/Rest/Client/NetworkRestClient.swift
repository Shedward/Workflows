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
    /// The request as sent: every part comes from the decorated request, and query values are
    /// percent-encoded here and nowhere else.
    static func urlRequest<RequestBody: DataEncodable, ResponseBody: DataDecodable>(
        for request: Request<RequestBody, ResponseBody>,
        at endpoint: Endpoint
    ) throws -> URLRequest {
        var url = endpoint.host
        if let path = request.path, let urlWithPath = URL(string: endpoint.host.absoluteString + path) {
            url = urlWithPath
        }

        var queryItems: [URLQueryItem] = []
        for (key, value) in request.query.values.sorted(by: { $0.key < $1.key }) {
            if let queryValue = value.queryValue {
                queryItems.append(URLQueryItem(name: key, value: queryValue))
            }
        }
        if !queryItems.isEmpty {
            url.append(queryItems: queryItems)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = request.headers.values
        urlRequest.httpBody = try request.body.data()
        if let contentType = request.body.contentType, urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }
        return urlRequest
    }

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

    public func fetch<RequestBody, ResponseBody>(
        _ request: Request<RequestBody, ResponseBody>
    ) async throws -> ResponseBody
    where RequestBody: DataEncodable, ResponseBody: DataDecodable {

        logger?.trace("→ Begin \(request.shortDescription, privacy: .public)")

        var responseData: Data?
        do {
            let decoratedRequest = try await Failure.wrap("Decorating request") {
                try await requestDecorators.decorate(request)
            }

            let urlRequest = try Failure.wrap("Composing request \(RequestBody.self)") {
                try Self.urlRequest(for: decoratedRequest, at: endpoint)
            }

            let (data, response) = try await Failure.wrap("Executing request") {
                try await session.data(for: urlRequest)
            }
            responseData = data

            do {
                try responseValidators.validate(response)
            } catch {
                throw ResponseRejected(
                    statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0,
                    body: data,
                    reason: (error as? DescriptiveError)?.userDescription ?? "\(error)"
                )
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
            let responseString = responseData.flatMap { String(data: $0, encoding: .utf8) } ?? "<no response>"
            logger?.error(
                """
                ← Failed \(request.shortDescription, privacy: .public)

                Error:
                \(error, privacy: .public)
                Response:
                \(responseString, privacy: .public)
                """
            )
            throw error
        }
    }

    private func responseDescription<Response>(_ urlResponse: URLResponse, responseBody: Response) -> String {
        guard let urlResponse = urlResponse as? HTTPURLResponse else {
            return "Response: -"
        }

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
