//
//  Formatters.swift
//
//
//  Created by Vladislav Maltsev on 12.08.2023.
//

import Foundation

enum Formatters {
    static let timestampFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withFullTime, .withFractionalSeconds]
        return formatter
    }()
}
