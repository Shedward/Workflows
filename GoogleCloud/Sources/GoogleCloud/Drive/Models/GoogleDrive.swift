//
//  GoogleDrive.swift
//
//
//  Created by v.maltsev on 14.08.2023.
//

public struct GoogleDrive {
    let client: GoogleDriveClient

    public init(accessToken: String) {
        self.client = GoogleDriveClient(accessToken: accessToken)
    }

    public init(authorizer: Authorizer) {
        self.client = GoogleDriveClient(authorizer: authorizer)
    }

    public func createFile(_ createFile: CreateFile) async throws -> File {
        let createRequest = CreateFileRequest(createFile: createFile)
        let newFileResponse = try await client.createFile(createFile: createRequest)
        let newFile = File(response: newFileResponse, client: client)
        return newFile
    }
}
