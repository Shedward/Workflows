//
//  AuthController.swift
//  WorkflowServer
//

import Core
import Foundation
import Hummingbird
import Rest

/// Exposes OAuth authorization endpoints.
///
/// Routes:
/// - `GET /auth`                                  — list all providers and their auth status
/// - `GET /auth/{service}`                        — `{ "url": "https://..." }` to start the flow
/// - `GET /auth/{service}/callback?code=&state=`  — OAuth callback; exchanges code, stores token
struct AuthController: Controller {

    // MARK: - Response types

    private struct AuthStatusItem: Encodable {
        let serviceId: String
        let displayName: String
        let authorized: Bool
    }

    private struct AuthURLResponse: Encodable {
        let url: String
    }

    // MARK: - Properties

    let registry: AuthRegistry

    var endpoints: RouteCollection<AppRequestContext> {
        RouteCollection(context: AppRequestContext.self)
            .get("auth", use: listProviders)
            .get("auth/:service", use: authorizationURL)
            .get("auth/:service/callback", use: handleCallback)
    }

    private let successHTML = """
        <!DOCTYPE html>
        <html>
        <head><meta charset="utf-8"><title>Authorization Successful</title></head>
        <body>
        <h2>Authorization successful!</h2>
        <p>You can close this tab and return to your workflow.</p>
        </body>
        </html>
        """

    // MARK: - Handlers

    private func listProviders(request: Request, context: Context) async throws -> Response {
        let providers = await registry.allProviders
        var items: [AuthStatusItem] = []
        for provider in providers {
            let authorized = await provider.isAuthorized()
            items.append(AuthStatusItem(
                serviceId: provider.serviceID,
                displayName: provider.displayName,
                authorized: authorized
            ))
        }
        return try jsonResponse(items)
    }

    private func requireProvider(context: Context) async throws -> any OAuthProvider {
        let serviceID = try context.parameters.require("service")
        guard let provider = await registry.provider(for: serviceID) else {
            throw HTTPError(.notFound, message: "Unknown auth service: \(serviceID)")
        }
        return provider
    }

    private func authorizationURL(request: Request, context: Context) async throws -> Response {
        let provider = try await requireProvider(context: context)
        let url = try await provider.authorizationURL()
        return try jsonResponse(AuthURLResponse(url: url.absoluteString))
    }

    private func handleCallback(request: Request, context: Context) async throws -> Response {
        let provider = try await requireProvider(context: context)

        guard
            let code = request.uri.queryParameters.get("code").map({ String($0) }),
            let state = request.uri.queryParameters.get("state").map({ String($0) })
        else {
            throw HTTPError(.badRequest, message: "Missing required 'code' or 'state' query parameters")
        }

        try await provider.handleCallback(code: code, state: state)

        return Response(
            status: .ok,
            headers: [.contentType: "text/html; charset=utf-8"],
            body: .init(byteBuffer: ByteBuffer(string: successHTML))
        )
    }

    // MARK: - Helpers

    private func jsonResponse<T: Encodable>(_ value: T) throws -> Response {
        let data = try Failure.wrap("Failed to encode auth response") {
            try JSONEncoder().encode(value)
        }
        return Response(
            status: .ok,
            headers: [.contentType: "application/json"],
            body: .init(byteBuffer: ByteBuffer(data: data))
        )
    }
}
