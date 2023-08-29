//
//  FileDetails.swift
//  
//
//  Created by v.maltsev on 14.08.2023.
//

public struct FileDetails {
    private let client: GoogleDriveClient

    public let id: String
    public let name: String

    init(response: FileResponse, client: GoogleDriveClient) {
        self.id = response.id
        self.name = response.name
        self.client = client
    }

    public func file() -> File {
        File(id: id, client: client)
    }
}
