//
//  CreateSpreadsheetRequest.swift
//
//
//  Created by v.maltsev on 14.08.2023.
//

import RestClient

struct CreateSpreadsheetRequest: JSONEncodableBody, Equatable {
    struct Properties: JSONEncodableBody, Equatable {
        var title: String
        var locale: String
    }

    var properties: Properties

    init(createSpreadsheet: CreateSpreadsheet) {
        self.properties = Properties(
            title: createSpreadsheet.title,
            locale: createSpreadsheet.locale
        )
    }

    init(properties: Properties) {
        self.properties = properties
    }
}
