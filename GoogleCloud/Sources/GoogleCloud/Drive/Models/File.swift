//
//  File.swift
//  
//
//  Created by v.maltsev on 14.08.2023.
//

public struct File {
    private let client: GoogleDriveClient

    let id: String
    let name: String

    init(response: FileResponse, client: GoogleDriveClient) {
        self.id = response.id
        self.name = response.name
        self.client = client
    }
}
