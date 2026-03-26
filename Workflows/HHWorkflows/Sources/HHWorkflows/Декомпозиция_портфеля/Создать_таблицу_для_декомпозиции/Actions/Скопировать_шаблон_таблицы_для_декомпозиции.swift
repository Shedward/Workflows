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
    @Input var portfolioKey: String
    @Output var spreadsheetId: String
    @Dependency var googleDrive: GoogleDriveClient

    func run() async throws {
        spreadsheetId = try await googleDrive.copyTemplate(named: portfolioKey)
    }
}
