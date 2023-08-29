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

    public init(authorizer: Authorizer) {
        self.client = GoogleSheetsClient(authorizer: authorizer)
    }

    public func spreadsheet(id: String) -> Spreadsheet {
        Spreadsheet(client: client, id: id)
    }

    public func createSpreadsheet(_ createSpreadsheet: CreateSpreadsheet) async throws -> SpreadsheetDetails {
        let request = CreateSpreadsheetRequest(createSpreadsheet: createSpreadsheet)
        let response = try await client.createSpreadsheet(createRequest: request)
        let spreadsheet = SpreadsheetDetails(response: response, client: client)
        return spreadsheet
    }
}
