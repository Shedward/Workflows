//
//  Скопировать_шаблон_таблицы_для_декомпозиции.swift
//  HHWorkflows
//
//  Created by Мальцев Владислав on 26.03.2026.
//

import GoogleServices
import WorkflowEngine

@DataBindable
struct Скопировать_шаблон_таблицы_для_декомпозиции: Action {
    private static let templateSpreadsheetId = "1V4VFXKHZSLltv_zYcD7i8WDMWPbVHrBvkkFM-3ZBx3M"
    private static let decompositionFolderId = "<decomposition-folder-id>"

    @Input var portfolioKey: String
    @Output var spreadsheetId: String
    @Dependency var googleDrive: GoogleDriveClient

    func run() async throws {
        spreadsheetId = try await googleDrive.copyFile(
            id: Self.templateSpreadsheetId,
            named: portfolioKey,
            to: Self.decompositionFolderId
        )
    }
}
