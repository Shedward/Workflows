//
//  GoogleDriveClient+Permissions.swift
//
//
//  Created by v.maltsev on 30.08.2023.
//

import RestClient

extension GoogleDriveClient {
    
    func createPermission(fileId: String, createPermission: CreateFilePermissionRequest) async throws {
        let request = RestRequest<CreateFilePermissionRequest, EmptyBody>(
            method: .post,
            path: "/v3/files/\(fileId)/permissions",
            body: createPermission
        )

        try await client.request(request)
    }
}
