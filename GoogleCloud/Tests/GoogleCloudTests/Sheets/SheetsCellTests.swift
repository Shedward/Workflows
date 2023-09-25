//
//  SheetsCellTests.swift
//
//
//  Created by v.maltsev on 25.09.2023.
//

@testable import GoogleCloud
import XCTest
import TestsPrelude

final class SheetsCellTests: XCTestCase {
    func testUpdateValues() async throws {
        let mock = GoogleSheetsMock()
        let googleSheets = GoogleSheets(mock: mock)

        await mock.setUpdateValues(
            spreadsheetId: "mock",
            valueRange: ValueRange(cell: "M0", value: .string("mock value")),
            stringInterpretation: .interpreted,
            response: .success(())
        )

        let cells = googleSheets.spreadsheet(id: "mock").cells("M0")
        try await cells.update(to: .string("mock value"))

        await mock.setUpdateValues(
            spreadsheetId: "mock",
            valueRange: ValueRange(cell: "M0", value: .string("mock value")),
            stringInterpretation: .interpreted,
            response: .failure(MockFailure("Failed request"))
        )

        await XCTExpectAsyncThrow(MockFailure("Failed request")) {
            try await cells.update(to: .string("mock value"))
        }
    }
}
