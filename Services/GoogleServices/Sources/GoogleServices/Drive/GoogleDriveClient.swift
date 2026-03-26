//
//  GoogleDriveClient.swift
//  GoogleServices
//

import Core
import Foundation
import Rest

public final class GoogleDriveClient: Sendable {
    private let rest: NetworkRestClient

    public init(tokenProvider: any AccessTokenAuthorizer) {
        let endpoint = NetworkRestClient.Endpoint(host: URL(string: "https://www.googleapis.com")!)
        self.rest = NetworkRestClient(
            endpoint: endpoint,
            requestDecorators: RequestDecoratorsSet().authorizer(tokenProvider)
        )
    }

    /// Copies a Drive file into the specified folder.
    /// Returns the new file's Drive ID.
    public func copyFile(id: String, named name: String, to folderId: String) async throws -> String {
        let body = CopyFileBody(name: name, parents: [folderId])
        let request = Request<CopyFileBody, DriveFileResponse>(
            .post,
            "/drive/v3/files/\(id)/copy?supportsAllDrives=true",
            body: body
        )
        let response = try await rest.fetch(request)
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
