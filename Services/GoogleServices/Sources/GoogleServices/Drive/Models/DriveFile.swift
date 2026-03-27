//
//  DriveFile.swift
//  GoogleServices
//

import Rest

/// A Google Drive file resource.
/// https://developers.google.com/drive/api/reference/rest/v3/files
public struct DriveFile: JSONDecodableBody {
    public let id: String
    public let name: String?
    public let mimeType: String?
}
