//
//  MockRestClient.swift
//
//
//  Created by v.maltsev on 23.09.2023.
//

import Prelude
import os

public actor MockRestClient: RestClient {

    private var handlers: [ErasedAnyMockRequestHandler] = []
    private let logger = Logger(scope: .mocks)

    public init() {
    }

    public func request<Request, Response>(
        _ request: RestRequest<Request, Response>
    ) async throws -> Response where Request : RestBodyEncodable, Response : RestBodyDecodable {
        let possibleHandlers = handlers
            .compactMap { $0 as? AnyMockRequestHandler<Request, Response> }
            .filter { $0.shouldAcceptRequest(request) }

        if possibleHandlers.count > 1 {
            logger.warning("Found \(possibleHandlers.count, privacy: .public) hanlders, last one is selected")
        }

        guard let handler = possibleHandlers.last else {
            throw Failure("""
            MockRestClient have no handler for request
            \(request.description)
            """)
        }

        logger.trace("→ (Mock) Begin \(request.shortDescription, privacy: .public)")

        do {
            let response = try handler.response(for: request)

            logger.trace(
            """
            ← (Mock) Finished \(request, privacy: .public)
            \(String(describing: response), privacy: .public)
            """
            )

            return response
        } catch {
            logger.error(
                """
                ← (Mock) Failed \(request.shortDescription, privacy: .public)

                Error:
                \(error, privacy: .public)
                """
            )
            throw error
        }
    }

    public func addHandler(_ handler: ErasedAnyMockRequestHandler) {
        handlers.append(handler)
    }
}
