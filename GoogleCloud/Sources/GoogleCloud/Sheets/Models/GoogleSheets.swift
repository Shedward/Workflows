//
//  GoogleSheets.swift
//
//
//  Created by v.maltsev on 14.08.2023.
//

public struct GoogleSheets {
    private let client: GoogleSheetsClient

    public init(accessToken: String) {
        self.client = GoogleSheetsClient(accessToken: accessToken)
    }

    public func createSpreadsheet(_ createSpreadsheet: CreateSpreadsheet) async throws -> Spreadsheet {
        let request = CreateSpreadsheetRequest(createSpreadsheet: createSpreadsheet)
        let response = try await client.createSpreadsheet(createRequest: request)
        let spreadsheet = Spreadsheet(response: response, client: client)
        return spreadsheet
    }
}
