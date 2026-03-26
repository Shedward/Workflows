//
//  GoogleSheetsClient.swift
//  GoogleServices
//

import Core
import Foundation
import Rest

public final class GoogleSheetsClient: Sendable {
    private let rest: NetworkRestClient

    public init(tokenProvider: any AccessTokenAuthorizer) {
        let endpoint = NetworkRestClient.Endpoint(host: URL(string: "https://sheets.googleapis.com")!)
        self.rest = NetworkRestClient(
            endpoint: endpoint,
            requestDecorators: RequestDecoratorsSet().authorizer(tokenProvider)
        )
    }

    /// Writes multiple cell values in a single batch request.
    public func batchUpdateValues(
        spreadsheetId: String,
        updates: [(range: String, value: String)]
    ) async throws {
        let body = BatchUpdateBody(
            valueInputOption: "USER_ENTERED",
            data: updates.map { BatchUpdateBody.ValueRange(range: $0.range, values: [[$0.value]]) }
        )
        let request = Request<BatchUpdateBody, EmptyBody>(
            .post,
            "/v4/spreadsheets/\(spreadsheetId)/values:batchUpdate",
            body: body
        )
        _ = try await rest.fetch(request)
    }
}

// MARK: - Request types

private struct BatchUpdateBody: JSONEncodableBody {
    let valueInputOption: String
    let data: [ValueRange]

    struct ValueRange: Encodable {
        let range: String
        let values: [[String]]
    }
}
