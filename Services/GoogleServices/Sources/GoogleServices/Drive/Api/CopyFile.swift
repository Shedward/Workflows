//
//  CopyFile.swift
//  GoogleServices
//
// https://developers.google.com/drive/api/reference/rest/v3/files/copy

import Core
import Rest

/// Creates a copy of a file in the user's My Drive or a shared drive.
public struct CopyFile: GoogleDriveApi {
    public typealias ResponseBody = DriveFile

    /// The ID of the file to copy.
    public var fileId: String

    // MARK: - Body

    /// The name of the copy.
    public var name: String?
    /// The IDs of the parent folders which contain the file.
    public var parents: [String]?
    /// A short description of the file.
    public var description: String?
    /// The MIME type of the file.
    public var mimeType: String?

    // MARK: - Query parameters

    /// Whether to ignore the domain's default visibility settings for the created file.
    public var ignoreDefaultVisibility: Bool?
    /// A comma-separated list of IDs of labels to include in the labelInfo part of the response.
    public var includeLabels: String?
    /// Specifies which additional view's permissions to include in the response.
    public var includePermissionsForView: String?
    /// Whether to set the 'keepForever' field in the new head revision.
    public var keepRevisionForever: Bool?
    /// A language hint for OCR processing during image import.
    public var ocrLanguage: String?
    /// Whether the requesting application supports both My Drives and shared drives.
    public var supportsAllDrives: Bool?

    public var request: RouteRequest {
        Request(.post, "/drive/v3/files/\(fileId)/copy", body: CopyFileBody(
            name: name,
            parents: parents,
            description: description,
            mimeType: mimeType
        ))
        .query(
            .set("ignoreDefaultVisibility",   to: ignoreDefaultVisibility)
            .set("includeLabels",             to: includeLabels)
            .set("includePermissionsForView", to: includePermissionsForView)
            .set("keepRevisionForever",       to: keepRevisionForever)
            .set("ocrLanguage",               to: ocrLanguage)
            .set("supportsAllDrives",         to: supportsAllDrives)
        )
    }

    public init(
        fileId: String,
        name: String? = nil,
        parents: [String]? = nil,
        description: String? = nil,
        mimeType: String? = nil,
        ignoreDefaultVisibility: Bool? = nil,
        includeLabels: String? = nil,
        includePermissionsForView: String? = nil,
        keepRevisionForever: Bool? = nil,
        ocrLanguage: String? = nil,
        supportsAllDrives: Bool? = nil
    ) {
        self.fileId = fileId
        self.name = name
        self.parents = parents
        self.description = description
        self.mimeType = mimeType
        self.ignoreDefaultVisibility = ignoreDefaultVisibility
        self.includeLabels = includeLabels
        self.includePermissionsForView = includePermissionsForView
        self.keepRevisionForever = keepRevisionForever
        self.ocrLanguage = ocrLanguage
        self.supportsAllDrives = supportsAllDrives
    }
}

extension CopyFile: Defaultable {
    public init() { self.init(fileId: "") }
}

extension CopyFile: Modifiers {
    public func name(_ name: String) -> Self                        { with { $0.name = name } }
    public func parents(_ parents: [String]) -> Self               { with { $0.parents = parents } }
    public func description(_ description: String) -> Self         { with { $0.description = description } }
    public func mimeType(_ mimeType: String) -> Self               { with { $0.mimeType = mimeType } }
    public func supportsAllDrives(_ value: Bool) -> Self           { with { $0.supportsAllDrives = value } }
    public func ignoreDefaultVisibility(_ value: Bool) -> Self     { with { $0.ignoreDefaultVisibility = value } }
    public func keepRevisionForever(_ value: Bool) -> Self         { with { $0.keepRevisionForever = value } }
    public func ocrLanguage(_ value: String) -> Self               { with { $0.ocrLanguage = value } }
    public func includeLabels(_ value: String) -> Self             { with { $0.includeLabels = value } }
    public func includePermissionsForView(_ value: String) -> Self { with { $0.includePermissionsForView = value } }
}

// MARK: - Request body

private struct CopyFileBody: JSONEncodableBody {
    let name: String?
    let parents: [String]?
    let description: String?
    let mimeType: String?
}
