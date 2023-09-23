//
//  DriveFileTests.swift
//
//
//  Created by v.maltsev on 24.09.2023.
//

@testable import GoogleCloud
import XCTest

final class DriveFileTests: XCTestCase {
    func testCreateFile() async throws {
        let mock = GoogleDriveMock()
        let drive = GoogleDrive(mock: mock)

        let createFile = CreateFile(name: "MockFile.txt")
        await mock.setCreateFileResponse(
            createFile: CreateFileRequest(createFile: createFile), response:
                FileResponse(id: "1", name: "MockFile.txt", webViewLink: nil)
        )
        let file = try await drive.createFile(createFile)
        XCTAssertEqual(file.name, "MockFile.txt")
    }

    func testGetFile() async throws {
        let mock = GoogleDriveMock()
        let drive = GoogleDrive(mock: mock)

        await mock.setGetFileResponse(
            fileId: "2",
            fields: ["id", "name"],
            response: FileResponse(id: "2", name: "ExistingFile.txt", webViewLink: nil)
        )

        let fileDetails = try await drive.file(id: "2").details()
        XCTAssertEqual(fileDetails.id, "2")
        XCTAssertEqual(fileDetails.name, "ExistingFile.txt")
    }

    func testCopy() async throws {
        let mock = GoogleDriveMock()
        let drive = GoogleDrive(mock: mock)

        let createCopyFile = CreateFileRequest(createFile: CreateFile(name: "CopyFile.txt"))
        await mock.setCopyFileResponse(
            sourceId: "1",
            to: createCopyFile,
            response: FileResponse(id: "2", name: "CopyFile.txt", webViewLink: nil)
        )

        let copyFile = try await drive.file(id: "1").copy(to: CreateFile(name: "CopyFile.txt"))
        XCTAssertEqual(copyFile.id, "2")
        XCTAssertEqual(copyFile.name, "CopyFile.txt")
    }
}
