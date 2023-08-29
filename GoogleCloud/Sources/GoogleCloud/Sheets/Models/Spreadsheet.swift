//
//  Spreadsheet.swift
//
//
//  Created by v.maltsev on 29.08.2023.
//

public struct Spreadsheet {
    private let client: GoogleSheetsClient

    public let id: String

    init(client: GoogleSheetsClient, id: String) {
        self.client = client
        self.id = id
    }

    public func cells(_ range: String) -> Cells {
        Cells(client: client, spreadsheetId: id, range: range)
    }
}
