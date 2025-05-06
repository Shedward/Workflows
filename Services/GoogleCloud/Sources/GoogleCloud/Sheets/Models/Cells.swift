//
//  Cells.swift
//
//
//  Created by v.maltsev on 29.08.2023.
//

public struct Cells {
    private let client: GoogleSheetsClient

    public let spreadsheetId: String
    public let range: String

    init(client: GoogleSheetsClient, spreadsheetId: String, range: String) {
        self.client = client
        self.spreadsheetId = spreadsheetId
        self.range = range
    }

    public func update(
        values: [[CellValue]],
        stringInterpretation: CellValueStringInterpretation = .interpreted
    ) async throws {
        let valueRange = ValueRange(range: range, values: values)
        try await client.updateValues(
            spreadsheetId: spreadsheetId,
            valueRange: valueRange,
            stringInterpretation: stringInterpretation
        )
    }

    public func update(
        to value: CellValue,
        stringInterpretation: CellValueStringInterpretation = .interpreted
    ) async throws {
        try await update(values: [[value]], stringInterpretation: stringInterpretation)
    }
}
