//
//  GoogleDriveClient.swift
//  GoogleServices
//

import Core
import Foundation
import Rest

public final class GoogleDriveClient: Sendable {
    private let rest: RestClient

    public init(tokenProvider: any AccessTokenAuthorizer) {
        let endpoint = NetworkRestClient.Endpoint(host: URL(string: "https://www.googleapis.com")!)
        self.rest = NetworkRestClient(
            endpoint: endpoint,
            requestDecorators: RequestDecoratorsSet().authorizer(tokenProvider)
        )
    }

    public func fetch<A: GoogleDriveApi>(_ api: A) async throws -> A.ResponseBody {
        try await rest.fetch(api)
    }
}
