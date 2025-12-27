//
//  QueryConvertible.swift
//  RestClient
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

private extension Collection where Element: QueryConvertible {
    func joinedQueryValue() -> String? {
        let parts = compactMap { $0.queryValue }
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
        map { $0.queryValue } ?? nil
    }
}

extension QueryConvertible where Self: RawRepresentable, Self.RawValue: QueryConvertible {
    public var queryValue: String? {
        rawValue.queryValue
    }
}
