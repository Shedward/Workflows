//
//  Заполнить_поля_таблицы_декомпозиции.swift
//  HHWorkflows
//
//  Created by Мальцев Владислав on 26.03.2026.
//

import GoogleServices
import WorkflowEngine

@DataBindable
struct Заполнить_поля_таблицы_декомпозиции: Action {
    @Input var portfolioKey: String
    @Input var spreadsheetId: String
    @Dependency var googleSheets: GoogleSheetsClient

    func run() async throws {
        try await googleSheets.batchUpdateValues(
            spreadsheetId: spreadsheetId,
            updates: [
                (range: "A1", value: portfolioKey),
                (range: "B14", value: "Mob"),
                (range: "B15", value: "iOS"),
            ]
        )
    }
}
