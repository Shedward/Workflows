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

        _ = try await restClient.request(request)
    }
}

extension GoogleDriveMock {

    func addCreatePermissionResponse(fileId: String, createPermission: CreateFilePermissionRequest, response: Result<Void, Error>) async {
        let filter = RestRequestFilter<CreateFilePermissionRequest, EmptyBody>(
            method: .exact(.post),
            path: .exact("/v3/files/\(fileId)/permissions"),
            body: .exact(createPermission)
        )
        
        await restClient.addResponse(for: filter, response: response.map { EmptyBody() })
    }
}
