//
//  SpreadsheetResponse.swift
//
//
//  Created by v.maltsev on 14.08.2023.
//

import RestClient

struct SpreadsheetResponse: JSONDecodableBody {

    struct Properties: JSONDecodableBody {
        let title: String
        let locale: String
    }

    let spreadsheetId: String
    let spreadsheetUrl: String
    let properties: Properties
}
