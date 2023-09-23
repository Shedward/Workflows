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

        return try await restClient.request(request)
    }

    func getFile(fileId: String, fields: [String]) async throws -> FileResponse {
        let request = RestRequest<EmptyBody, FileResponse>(
            method: .get,
            path: "/v3/files/\(fileId)",
            query: RestQuery()
                .set("fields", toCommaSeparated: fields)
        )

        return try await restClient.request(request)
    }

    func copyFile(sourceId: String, to createFile: CreateFileRequest) async throws -> FileResponse {
        let request = RestRequest<CreateFileRequest, FileResponse>(
            method: .post,
            path: "/v3/files/\(sourceId)/copy",
            body: createFile
        )

        return try await restClient.request(request)
    }
}

extension GoogleDriveMock {
    
    func setCreateFileResponse(createFile: CreateFileRequest, response: FileResponse) async {
        let filter = RestRequestFilter<CreateFileRequest, FileResponse>(
            method: .exact(.post),
            path: .exact("/v3/files"),
            body: .exact(createFile)
        )

        await restClient.addResponse(for: filter, response: response)
    }

    func setGetFileResponse(fileId: String, fields: [String], response: FileResponse) async {
        let filter = RestRequestFilter<EmptyBody, FileResponse>(
            method: .exact(.get),
            path: .exact("/v3/files/\(fileId)"),
            query: .exact(RestQuery().set("fields", toCommaSeparated: fields))
        )

        await restClient.addResponse(for: filter, response: response)
    }

    func setCopyFileResponse(sourceId: String, to createFile: CreateFileRequest, response: FileResponse) async {
        let filter = RestRequestFilter<CreateFileRequest, FileResponse>(
            method: .exact(.post),
            path: .exact("/v3/files/\(sourceId)/copy"),
            body: .exact(createFile)
        )

        await restClient.addResponse(for: filter, response: response)
    }
}
