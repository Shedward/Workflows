//
//  Decoders.swift
//
//
//  Created by Vladislav Maltsev on 12.08.2023.
//

import Prelude
import Foundation

enum Decoders {
    static let decoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let timeString = try container.decode(String.self)
            guard let time = Formatters.timestampFormatter.date(from: timeString) else {
                throw Failure("Wrong timestamp format: \(timeString)")
            }
            return time
        }
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}
