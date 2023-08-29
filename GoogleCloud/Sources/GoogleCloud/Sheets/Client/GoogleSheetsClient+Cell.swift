//
//  GoogleSheetsClient+Cells.swift
//
//
//  Created by v.maltsev on 29.08.2023.
//

import RestClient

extension GoogleSheetsClient {
    func updateValues(
        spreadsheetId: String,
        valueRange: ValueRange,
        stringInterpretation: CellValueStringInterpretation
    ) async throws {
        let request = RestRequest<ValueRange, EmptyBody>(
            method: .put,
            path: "v4/spreadsheets/\(spreadsheetId)/values/\(valueRange.range)",
            query: RestQuery
                .set("valueInputOption", to: stringInterpretation.rawValue),
            body: valueRange
        )

        try await client.request(request)
    }
}
