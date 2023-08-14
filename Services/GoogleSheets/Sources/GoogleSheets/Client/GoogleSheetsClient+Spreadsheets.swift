//
//  GoogleSheetsClient+Spreadsheets.swift
//
//
//  Created by v.maltsev on 14.08.2023.
//

import RestClient

extension GoogleSheetsClient {
    func createSpreadsheet(createRequest: CreateSpreadsheetRequest) async throws -> SpreadsheetResponse {
        let request = RestRequest<CreateSpreadsheetRequest, SpreadsheetResponse>(
            method: .post,
            path: "/v4/spreadsheets",
            body: createRequest
        )

        return try await client.request(request)
    }
}
