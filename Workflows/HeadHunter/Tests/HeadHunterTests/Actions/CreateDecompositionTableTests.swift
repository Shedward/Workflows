//
//  CreateDecompositionTableTests.swift
//
//
//  Created by Vlad Maltsev on 30.09.2023.
//

@testable import HeadHunter
@testable import Jira
@testable import GoogleCloud

import XCTest

final class CreateDecompositionTableTests: XCTestCase {
    func testSuccessfulFlow() async throws {
        let mocks = Mocks()
        let dependencies = MockDependencies(mocks: mocks)
        let config = DecompositionConfig(
            templateFileId: "mock_template_file_id",
            decompositionsFolderId: "mock_decompositions_folder_id",
            titleCell: "TITLE_CELL",
            projectKeyCell: "PROJECT_KEY_CELL",
            projectKey: "MOCK_PROJECT"
        )
        
        await mocks.jira.setGetIssueResponse(
            key: "PORTFOLIO-MOCK",
            fields: SummaryFields.self,
            response: .success(.init(id: "mock-1", key: "PORTFOLIO-MOCK", fields: SummaryFields(summary: "Implement mock")))
        )
        await mocks.googleDrive.setCopyFileResponse(
            sourceId: "mock_template_file_id",
            to: CreateFileRequest(
                createFile: .init(
                    name: "PORTFOLIO-MOCK: Implement mock",
                    parents: ["mock_decompositions_folder_id"]
                )
            ),
            response: .success(
                FileResponse(
                    id: "mock_decomposition_file_id",
                    name: "mock_decomposition_file_name",
                    webViewLink: nil
                )
            )
        )
        await mocks.googleSheets.setUpdateValues(
            spreadsheetId: "mock_decomposition_file_id",
            valueRange: ValueRange(cell: "TITLE_CELL", value: .string("PORTFOLIO-MOCK")),
            stringInterpretation: .interpreted,
            response: .success(())
        )
        await mocks.googleSheets.setUpdateValues(
            spreadsheetId: "mock_decomposition_file_id",
            valueRange: ValueRange(cell: "PROJECT_KEY_CELL", value: .string("MOCK_PROJECT")),
            stringInterpretation: .interpreted,
            response: .success(())
        )
        await mocks.googleDrive.setCreatePermissionResponse(
            fileId: "mock_decomposition_file_id",
            createPermission: CreateFilePermissionRequest(type: "anyone", role: "reader", emailAddress: nil, domain: nil),
            response: .success(())
        )
        await mocks.googleDrive.setGetFileResponse(
            fileId: "mock_decomposition_file_id",
            fields: ["id", "name", "webViewLink"],
            response: .success(
                FileResponse(
                    id: "mock_decomposition_file_id",
                    name: "PORTFOLIO-MOCK: Implement mock",
                    webViewLink: "https://sheet.google.com/mock_decomposition_file_id"
                )
            )
        )
        
        let action = CreateDecompositionTableAction(deps: dependencies, config: config)
        let input = CreateDecompositionTableAction.Input(portfolioKey: "PORTFOLIO-MOCK")
        let output = try await action.perform(input)
        XCTAssertEqual(output.decompositonUrl, "https://sheet.google.com/mock_decomposition_file_id")
    }
}
