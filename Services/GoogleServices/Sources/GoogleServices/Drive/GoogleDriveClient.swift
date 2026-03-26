//
//  GoogleDriveClient.swift
//  GoogleServices
//

import Core
import Foundation
import Rest

public final class GoogleDriveClient: Sendable {
    private let rest: NetworkRestClient
    private let templateSpreadsheetId: String
    private let decompositionFolderId: String

    public init(
        tokenProvider: ServiceAccountTokenProvider,
        templateSpreadsheetId: String,
        decompositionFolderId: String
    ) {
        let endpoint = NetworkRestClient.Endpoint(host: URL(string: "https://www.googleapis.com")!)
        self.rest = NetworkRestClient(
            endpoint: endpoint,
            requestDecorators: RequestDecoratorsSet().authorizer(tokenProvider)
        )
        self.templateSpreadsheetId = templateSpreadsheetId
        self.decompositionFolderId = decompositionFolderId
    }

    /// Copies the template spreadsheet into the decomposition folder.
    /// Returns the new file's Drive ID.
    public func copyTemplate(named name: String) async throws -> String {
        let body = CopyFileBody(name: name, parents: [decompositionFolderId])
        let request = Request(
            .post,
            "/drive/v3/files/\(templateSpreadsheetId)/copy",
            body: body
        )
        let response: DriveFileResponse = try await rest.fetch(request)
        return response.id
    }
}

// MARK: - Request / Response types

private struct CopyFileBody: JSONEncodableBody {
    let name: String
    let parents: [String]
}

private struct DriveFileResponse: JSONDecodableBody {
    let id: String
}
