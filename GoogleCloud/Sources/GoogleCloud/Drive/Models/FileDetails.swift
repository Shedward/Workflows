//
//  FileDetails.swift
//  
//
//  Created by v.maltsev on 14.08.2023.
//

public struct FileDetails {
    public enum Fields: String {
        case id
        case name
        case webViewLink

        static let required: [Fields] = [.id, .name]
    }

    private let client: GoogleDriveClient

    public let id: String
    public let name: String

    public let webViewLink: String?

    init(response: FileResponse, client: GoogleDriveClient) {
        self.id = response.id
        self.name = response.name
        self.webViewLink = response.webViewLink
        self.client = client
    }

    public func file() -> File {
        File(id: id, client: client)
    }
}
