//
//  BatchUpdateValues.swift
//  GoogleServices
//
// https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values/batchUpdate

import Core
import Rest

/// Sets values in one or more ranges of a spreadsheet.
public struct BatchUpdateValues: GoogleSheetsApi {

    /// The ID of the spreadsheet to update.
    public var spreadsheetId: String

    /// How the input data should be interpreted.
    public var valueInputOption: ValueInputOption
    /// The new values to apply to the spreadsheet.
    public var data: [ValueRange]
    /// Determines if the update response should include the values of the cells that were updated.
    public var includeValuesInResponse: Bool?
    /// Determines how dates, times, and durations in the response should be rendered.
    public var responseDateTimeRenderOption: DateTimeRenderOption?
    /// Determines how values in the response should be rendered.
    public var responseValueRenderOption: ValueRenderOption?

    public var request: RouteRequest {
        Request(.post, "/v4/spreadsheets/\(spreadsheetId)/values:batchUpdate", body: BatchUpdateValuesBody(
            valueInputOption: valueInputOption.rawValue,
            data: data,
            includeValuesInResponse: includeValuesInResponse,
            responseDateTimeRenderOption: responseDateTimeRenderOption?.rawValue,
            responseValueRenderOption: responseValueRenderOption?.rawValue
        ))
    }

    public init(
        spreadsheetId: String,
        valueInputOption: ValueInputOption = .userEntered,
        data: [ValueRange] = []
    ) {
        self.spreadsheetId = spreadsheetId
        self.valueInputOption = valueInputOption
        self.data = data
    }
}

extension BatchUpdateValues: Defaultable {
    public init() { self.init(spreadsheetId: "") }
}

extension BatchUpdateValues: Modifiers {
    public func valueInputOption(_ option: ValueInputOption) -> Self         { with { $0.valueInputOption = option } }
    public func data(_ data: [ValueRange]) -> Self                           { with { $0.data = data } }
    public func includeValuesInResponse(_ value: Bool) -> Self               { with { $0.includeValuesInResponse = value } }
    public func responseDateTimeRenderOption(_ v: DateTimeRenderOption) -> Self { with { $0.responseDateTimeRenderOption = v } }
    public func responseValueRenderOption(_ v: ValueRenderOption) -> Self    { with { $0.responseValueRenderOption = v } }
}

extension BatchUpdateValues {
    /// Determines how input data should be interpreted.
    public enum ValueInputOption: String {
        /// Values will be parsed as if the user typed them into the UI.
        case userEntered = "USER_ENTERED"
        /// Values will not be parsed and will be stored as-is.
        case raw = "RAW"
    }

    /// Determines how dates and times in the response should be rendered.
    public enum DateTimeRenderOption: String {
        /// Instructs date, time, datetime, and duration fields to be output as doubles.
        case serialNumber = "SERIAL_NUMBER"
        /// Instructs date, time, datetime, and duration fields to be output as strings.
        case formattedString = "FORMATTED_STRING"
    }

    /// Determines how values in the response should be rendered.
    public enum ValueRenderOption: String {
        /// Values will be calculated and formatted according to the cell's formatting.
        case formattedValue = "FORMATTED_VALUE"
        /// Values will be calculated but not formatted.
        case unformattedValue = "UNFORMATTED_VALUE"
        /// Values will not be calculated; the reply will include the formulas.
        case formula = "FORMULA"
    }

    /// A range of values in a spreadsheet.
    public struct ValueRange: Encodable, Sendable {
        /// The range the values cover in A1 notation.
        public let range: String
        /// The data that was read or to be written.
        public let values: [[String]]

        public init(range: String, values: [[String]]) {
            self.range = range
            self.values = values
        }
    }
}

// MARK: - Request body

private struct BatchUpdateValuesBody: JSONEncodableBody {
    let valueInputOption: String
    let data: [BatchUpdateValues.ValueRange]
    let includeValuesInResponse: Bool?
    let responseDateTimeRenderOption: String?
    let responseValueRenderOption: String?
}
