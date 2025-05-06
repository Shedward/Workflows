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
            query: RestQuery()
                .set("valueInputOption", to: stringInterpretation.rawValue),
            body: valueRange
        )

        _ = try await client.request(request)
    }
}

extension GoogleSheetsMock {
    func addUpdateValues(
        spreadsheetId: String,
        valueRange: ValueRange,
        stringInterpretation: CellValueStringInterpretation,
        response: Result<Void, Error>
    ) async {
        let filter = RestRequestFilter<ValueRange, EmptyBody>(
            method: .exact(.put),
            path: .exact("v4/spreadsheets/\(spreadsheetId)/values/\(valueRange.range)"),
            query: .exact(
                RestQuery()
                    .set("valueInputOption", to: stringInterpretation.rawValue)
            ),
            body: .exact(valueRange)
        )

        await restClient.addResponse(for: filter, response: response.map { EmptyBody() })
    }
}
