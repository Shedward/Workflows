//
//  GoogleSheetsClient.swift
//  GoogleServices
//

import Core
import Foundation
import Rest

public final class GoogleSheetsClient: Sendable {
    private let rest: RestClient

    public init(tokenProvider: any AccessTokenAuthorizer) {
        let endpoint = NetworkRestClient.Endpoint(host: URL(string: "https://sheets.googleapis.com")!)
        self.rest = NetworkRestClient(
            endpoint: endpoint,
            requestDecorators: RequestDecoratorsSet().authorizer(tokenProvider)
        )
    }

    public func fetch<A: GoogleSheetsApi>(_ api: A) async throws -> A.ResponseBody {
        try await rest.fetch(api)
    }
}
