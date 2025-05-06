//
//  CreateSpreadsheet.swift
//
//
//  Created by v.maltsev on 14.08.2023.
//

import Foundation

public struct CreateSpreadsheet {
    public let title: String
    public let locale: String

    public init(title: String, locale: String = Locale.current.identifier) {
        self.title = title
        self.locale = locale
    }
}
