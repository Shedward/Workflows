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
}
