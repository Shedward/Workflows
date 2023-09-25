//
//  DriveFileTests.swift
//
//
//  Created by v.maltsev on 24.09.2023.
//

@testable import GoogleCloud
import XCTest
import TestsPrelude

final class DriveFileTests: XCTestCase {
    func testCreateFile() async throws {
        let mock = GoogleDriveMock()
        let drive = GoogleDrive(mock: mock)

        let createFile = CreateFile(name: "MockFile.txt")
        await mock.setCreateFileResponse(
            createFile: CreateFileRequest(createFile: createFile), 
            response: .success(FileResponse(id: "1", name: "MockFile.txt", webViewLink: nil))
        )

        let file = try await drive.createFile(createFile)
        XCTAssertEqual(file.name, "MockFile.txt")

        await mock.setCreateFileResponse(
            createFile: CreateFileRequest(createFile: createFile),
            response: .failure(MockFailure("Request failed"))
        )

        await XCTExpectAsyncThrow(MockFailure("Request failed")) {
            _ = try await drive.createFile(createFile)
        }
    }

    func testGetFile() async throws {
        let mock = GoogleDriveMock()
        let drive = GoogleDrive(mock: mock)

        await mock.setGetFileResponse(
            fileId: "2",
            fields: ["id", "name"],
            response: .success(FileResponse(id: "2", name: "ExistingFile.txt", webViewLink: nil))
        )

        let fileDetails = try await drive.file(id: "2").details()
        XCTAssertEqual(fileDetails.id, "2")
        XCTAssertEqual(fileDetails.name, "ExistingFile.txt")

        await mock.setGetFileResponse(
            fileId: "2",
            fields: ["id", "name"],
            response: .failure(MockFailure("Request failed"))
        )

        await XCTExpectAsyncThrow(MockFailure("Request failed")) {
            _ = try await drive.file(id: "2").details()
        }
    }

    func testCopy() async throws {
        let mock = GoogleDriveMock()
        let drive = GoogleDrive(mock: mock)

        let createCopyFile = CreateFileRequest(createFile: CreateFile(name: "CopyFile.txt"))
        await mock.setCopyFileResponse(
            sourceId: "1",
            to: createCopyFile,
            response: .success(FileResponse(id: "2", name: "CopyFile.txt", webViewLink: nil))
        )

        let copyFile = try await drive.file(id: "1").copy(to: CreateFile(name: "CopyFile.txt"))
        XCTAssertEqual(copyFile.id, "2")
        XCTAssertEqual(copyFile.name, "CopyFile.txt")

        await mock.setCopyFileResponse(
            sourceId: "1",
            to: createCopyFile,
            response: .failure(MockFailure("Request failed"))
        )

        await XCTExpectAsyncThrow(MockFailure("Request failed")) {
            _ = try await drive.file(id: "1").copy(to: CreateFile(name: "CopyFile.txt"))
        }
    }
}
