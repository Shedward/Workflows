//
//  GoogleDriveClient+Files.swift
//
//
//  Created by v.maltsev on 14.08.2023.
//

import RestClient

extension GoogleDriveClient {

    func createFile(createFile: CreateFileRequest) async throws -> FileResponse {
        let request = RestRequest<CreateFileRequest, FileResponse>(
            method: .post,
            path: "/v3/files",
            body: createFile
        )

        return try await client.request(request)
    }

    func getFile(fileId: String, fields: [String]) async throws -> FileResponse {
        let request = RestRequest<EmptyBody, FileResponse>(
            method: .get,
            path: "/v3/files/\(fileId)",
            query: RestQuery
                .set("fields", to: fields.joined(separator: ","))
        )

        return try await client.request(request)
    }

    func copyFile(sourceId: String, to createFile: CreateFileRequest) async throws -> FileResponse {
        let request = RestRequest<CreateFileRequest, FileResponse>(
            method: .post,
            path: "/v3/files/\(sourceId)/copy",
            body: createFile
        )

        return try await client.request(request)
    }
}
