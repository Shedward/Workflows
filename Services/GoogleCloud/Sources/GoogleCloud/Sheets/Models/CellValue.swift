//
//  CellValue.swift
//
//
//  Created by v.maltsev on 29.08.2023.
//

public enum CellValueStringInterpretation: String, Sendable {
    case raw = "RAW"
    case interpreted = "USER_ENTERED"
}

public enum CellValue: Codable, Sendable, Equatable {
    case empty
    case string(String)
    case number(Double)
    case bool(Bool)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let stringValue = try? container.decode(String.self) {
            if stringValue.isEmpty {
                self = .empty
            } else {
                self = .string(stringValue)
            }
        }

        if let numberValue = try? container.decode(Double.self) {
            self = .number(numberValue)
        }

        if let boolValue = try? container.decode(Bool.self) {
            self = .bool(boolValue)
        }

        throw DecodingError.typeMismatch(
            CellValue.self,
            DecodingError.Context.init(
                codingPath: container.codingPath,
                debugDescription: "Invalid content. Expected string, value or bool",
                underlyingError: nil
            )
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .empty:
            try container.encode("")
        case .string(let stringValue):
            try container.encode(stringValue)
        case .number(let numberValue):
            try container.encode(numberValue)
        case .bool(let boolValue):
            try container.encode(boolValue)
        }
    }
}

extension CellValue: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self = .string(value)
    }
}

extension CellValue: ExpressibleByFloatLiteral {
    public init(floatLiteral value: FloatLiteralType) {
        self = .number(value)
    }
}

extension CellValue: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .number(Double(value))
    }
}

extension CellValue: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .bool(value)
    }
}

extension CellValue: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .empty
    }
}
