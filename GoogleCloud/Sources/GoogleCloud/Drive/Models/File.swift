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
        let copyFileResponse = try await client.copyFile(sourceId: id, to: createRequest)
        let copyFile = FileDetails(response: copyFileResponse, client: client)
        return copyFile
    }

    public func details(fields: Set<FileDetails.Fields> = []) async throws -> FileDetails {
        let fields = (FileDetails.Fields.required + fields).map(\.rawValue)
        let fileResponse = try await client.getFile(fileId: id, fields: fields)
        let fileDetails = FileDetails(response: fileResponse, client: client)
        return fileDetails
    }

    public func permissions() -> FilePermissions {
        FilePermissions(client: client, fileId: id)
    }
}
