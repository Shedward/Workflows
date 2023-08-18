//
//  Spreadsheet.swift
//
//
//  Created by v.maltsev on 14.08.2023.
//

public struct Spreadsheet {
    private let client: GoogleSheetsClient

    public let id: String
    public let url: String

    init(response: SpreadsheetResponse, client: GoogleSheetsClient) {
        self.client = client
        self.id = response.spreadsheetId
        self.url = response.spreadsheetUrl
    }
}
