//
//  Expiring.swift
//
//
//  Created by v.maltsev on 22.08.2023.
//

import Foundation

public struct Expiring<Value> {
    private let value: Value
    public let expirationTime: Date

    public init(value: Value, expirationTime: Date) {
        self.value = value
        self.expirationTime = expirationTime
    }

    public init(value: Value, expiresIn expirationInterval: TimeInterval, from date: Date = Date()) {
        self.init(value: value, expirationTime: date.addingTimeInterval(expirationInterval))
    }

    public func isExpired(at date: Date = Date()) -> Bool {
        expirationTime < date
    }

    public func isExpired(after delay: TimeInterval) -> Bool {
        isExpired(at: Date().addingTimeInterval(delay))
    }

    public func now() -> Value? {
        at(Date())
    }

    public func after(_ delay: TimeInterval) -> Value? {
        at(Date().addingTimeInterval(delay))
    }

    public func at(_ date: Date) -> Value? {
        guard !isExpired(at: date) else { return nil }
        return value
    }

    public func unexpired() -> Value {
        value
    }
}

extension Expiring {
    public func map<Other>(_ transform: (Value) -> Other) -> Expiring<Other> {
        .init(value: transform(value), expirationTime: expirationTime)
    }
}

extension Expiring: Equatable where Value: Equatable {
}

extension Expiring: Encodable where Value: Encodable {
}

extension Expiring: Decodable where Value: Decodable {
}
