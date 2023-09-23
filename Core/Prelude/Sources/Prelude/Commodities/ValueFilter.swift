//
//  ValueFilter.swift
//
//
//  Created by v.maltsev on 23.09.2023.
//

import Foundation

public struct ValueFilter<T> {
    let isMatching: (T) -> Bool

    init(isMatching: @escaping (T) -> Bool) {
        self.isMatching = isMatching
    }

    public func matching(_ value: T) -> Bool {
        isMatching(value)
    }

    public static func custom(_ isMatching: @escaping (T) -> Bool) -> ValueFilter {
        ValueFilter(isMatching: isMatching)
    }
}

extension ValueFilter {
    public static func any() -> ValueFilter {
        ValueFilter { _ in true }
    }
}

extension ValueFilter where T: Equatable {
    public static func exact(_ value: T) -> ValueFilter {
        ValueFilter { $0 == value }
    }
}

extension ValueFilter where T == String {
    public static func startsWith(_ prefix: String) -> ValueFilter {
        ValueFilter { $0.starts(with: prefix) }
    }
}
