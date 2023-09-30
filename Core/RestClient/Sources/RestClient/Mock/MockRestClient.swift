//
//  MockRestClient.swift
//
//
//  Created by v.maltsev on 23.09.2023.
//

import Prelude
import os

public actor MockRestClient: RestClient {

    private let label: StaticString
    private var handlers: [ErasedAnyMockRequestHandler] = []
    private let logger = Logger(scope: .network)

    public init(_ label: StaticString) {
        self.label = label
    }

    public func request<Request, Response>(
        _ request: RestRequest<Request, Response>
    ) async throws -> Response where Request : RestBodyEncodable, Response : RestBodyDecodable {
        var firstHandler: AnyMockRequestHandler<Request, Response>?
        handlers = handlers.filter { handler in
            guard firstHandler == nil else { return true }
            if
                let possibleHandler = handler as? AnyMockRequestHandler<Request, Response>,
                possibleHandler.shouldAcceptRequest(request) 
            {
                firstHandler = possibleHandler
                return false
            }
                
            return true
        }

        guard let handler = firstHandler else {
            throw Failure("""
            MockRestClient(\(label)) have no handler for request
            \(request.description)
            """)
        }

        logger.trace("→ Mock(\(self.label) Begin \(request.shortDescription, privacy: .public)")

        do {
            let response = try handler.response(for: request)

            logger.trace(
            """
            ← Mock(\(self.label) Finished \(request, privacy: .public)
            \(String(describing: response), privacy: .public)
            """
            )

            return response
        } catch {
            logger.error(
                """
                ← Mock(\(self.label) Failed \(request.shortDescription, privacy: .public)

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
