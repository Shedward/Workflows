//
//  File.swift
//  
//
//  Created by v.maltsev on 29.08.2023.
//

public struct File {
    private let client: GoogleDriveClient

    public let id: String

    init(id: String, client: GoogleDriveClient) {
        self.id = id
        self.client = client
    }

    public func copy(to createFile: CreateFile) async throws -> FileDetails {
        let createRequest = CreateFileRequest(createFile: createFile)
        let copyFileResponse = try await client.copy(sourceId: id, to: createRequest)
        let copyFile = FileDetails(response: copyFileResponse, client: client)
        return copyFile
    }
}
