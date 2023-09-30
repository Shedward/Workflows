//
//  DrivePermissionsTests.swift
//
//
//  Created by v.maltsev on 25.09.2023.
//

@testable import GoogleCloud
import XCTest
import TestsPrelude

final class DrivePermissionsTests: XCTestCase {
    func testCreatePermission() async throws {
        let mock = GoogleDriveMock()
        let googleDrive = GoogleDrive(mock: mock)

        await mock.setCreatePermissionResponse(
            fileId: "mock-file",
            createPermission: CreateFilePermissionRequest(
                type: "user",
                role: "writer",
                emailAddress: "mock@user.com",
                domain: nil
            ),
            response: .success(())
        )

        try await googleDrive.file(id: "mock-file")
            .permissions()
            .create(.init(group: .user(emailAddress: "mock@user.com"), role: .writer))
    }
    
    func testCreatePermissionFailure() async throws {
        let mock = GoogleDriveMock()
        let googleDrive = GoogleDrive(mock: mock)
        
        await mock.setCreatePermissionResponse(
            fileId: "mock-file",
            createPermission: CreateFilePermissionRequest(
                type: "user",
                role: "writer",
                emailAddress: "mock@user.com",
                domain: nil
            ),
            response: .failure(MockFailure("Failed request"))
        )

        await XCTExpectAsyncThrow(MockFailure("Failed request")) {
            try await googleDrive.file(id: "mock-file")
                .permissions()
                .create(.init(group: .user(emailAddress: "mock@user.com"), role: .writer))
        }
    }
}
