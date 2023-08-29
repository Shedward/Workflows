//
//  ValueRange.swift
//
//
//  Created by v.maltsev on 29.08.2023.
//

import RestClient

struct ValueRange: JSONCodableBody {
    var range: String
    var majorDimension: Dimension = .rows
    var values: [[CellValue]]

    init(
        range: String,
        majorDimension: Dimension = .rows,
        values: [[CellValue]]
    ) {
        self.range = range
        self.majorDimension = majorDimension
        self.values = values
    }

    init(cell: String, value: CellValue) {
        self.init(range: cell, values: [[value]])
    }
}
