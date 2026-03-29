//
//  QueryConvertible.swift
//  Rest
//
//  Created by Vlad Maltsev on 24.12.2025.
//

public protocol QueryConvertible: Sendable {
    var queryValue: String? { get }
}

extension String: QueryConvertible {
    public var queryValue: String? {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
}

extension Int: QueryConvertible {
    public var queryValue: String? { String(self) }
}

extension Bool: QueryConvertible {
    public var queryValue: String? { self ? "true" : "false" }
}

private extension Collection where Element: QueryConvertible {
    func joinedQueryValue() -> String? {
        let parts = compactMap(\.queryValue)
        return parts.isEmpty ? nil : parts.joined(separator: ",")
    }
}

extension Array: QueryConvertible where Element: QueryConvertible {
    public var queryValue: String? {
        joinedQueryValue()
    }
}

extension Set: QueryConvertible where Element: QueryConvertible {
    public var queryValue: String? {
        joinedQueryValue()
    }
}

extension Optional: QueryConvertible where Wrapped: QueryConvertible {
    public var queryValue: String? {
        flatMap(\.queryValue)
    }
}

extension QueryConvertible where Self: RawRepresentable, Self.RawValue: QueryConvertible {
    public var queryValue: String? {
        rawValue.queryValue
    }
}
