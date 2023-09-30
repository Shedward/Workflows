//
//  SheetsSpreadsheetsTests.swift
//
//
//  Created by v.maltsev on 25.09.2023.
//

@testable import GoogleCloud
import XCTest
import TestsPrelude

final class SheetsSpreadsheetsTests: XCTestCase {
    func testCreateSpreadsheets() async throws {
        let mock = GoogleSheetsMock()
        let googleSheets = GoogleSheets(mock: mock)

        let createSpreadsheet = CreateSpreadsheet(title: "MockSheet")

        await mock.addCreateSpreadsheetResponse(
            createRequest: CreateSpreadsheetRequest(
                properties: .init(title: "MockSheet", locale: Locale.current.identifier)
            ),
            response: .success(
                SpreadsheetResponse(
                    spreadsheetId: "1",
                    spreadsheetUrl: "https://mock.sheet.url",
                    properties: .init(title: "Mock", locale: "ru_RU")
                )
            )
        )
        
        let response = try await googleSheets.createSpreadsheet(createSpreadsheet)
        XCTAssertEqual(response.url, "https://mock.sheet.url")
    }
    
    func testCreateSpreadsheetsFailure() async throws {
        let mock = GoogleSheetsMock()
        let googleSheets = GoogleSheets(mock: mock)
        
        await mock.addCreateSpreadsheetResponse(
            createRequest: CreateSpreadsheetRequest(
                properties: .init(title: "MockSheet", locale: Locale.current.identifier)
            ),
            response: .failure(MockFailure("Failed request"))
        )

        await XCTExpectAsyncThrow(MockFailure("Failed request")) {
            let createSpreadsheet = CreateSpreadsheet(title: "MockSheet")
            _ = try await googleSheets.createSpreadsheet(createSpreadsheet)
        }
    }
}
