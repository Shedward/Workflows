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
        _ = try await googleSheets.fetch(
            BatchUpdateValues(spreadsheetId: spreadsheetId)
                .data([
                    BatchUpdateValues.ValueRange(range: "A1", values: [[portfolioKey]]),
                    BatchUpdateValues.ValueRange(range: "B14", values: [["Mob"]]),
                    BatchUpdateValues.ValueRange(range: "B15", values: [["iOS"]])
                ])
        )
    }
}
