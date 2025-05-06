//
//  FilePermission.swift
//
//
//  Created by v.maltsev on 29.08.2023.
//

public enum PermissionGroup {
    case user(emailAddress: String)
    case group(emailAddress: String)
    case domain(String)
    case anyone
}

public enum PermissionRole {
    case organizer
    case fileOrganizer
    case writer
    case commenter
    case reader
}

public struct CreateFilePermission {
    public var group: PermissionGroup
    public var role: PermissionRole

    public init(group: PermissionGroup, role: PermissionRole) {
        self.group = group
        self.role = role
    }
}

public struct FilePermissions {
    private let client: GoogleDriveClient
    public let fileId: String

    init(client: GoogleDriveClient, fileId: String) {
        self.client = client
        self.fileId = fileId
    }

    public func create(_ createPermission: CreateFilePermission) async throws {
        let request = CreateFilePermissionRequest(createPermission: createPermission)
        try await client.createPermission(fileId: fileId, createPermission: request)
    }
}
