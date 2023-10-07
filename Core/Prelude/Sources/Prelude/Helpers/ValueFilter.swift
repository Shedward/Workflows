//
//  ValueFilter.swift
//
//
//  Created by v.maltsev on 23.09.2023.
//

import Foundation

public struct Filter<T> {
    let isMatching: (T) -> Bool

    init(isMatching: @escaping (T) -> Bool) {
        self.isMatching = isMatching
    }

    public func matching(_ value: T) -> Bool {
        isMatching(value)
    }

    public static func custom(_ isMatching: @escaping (T) -> Bool) -> Filter {
        Filter(isMatching: isMatching)
    }
}

extension Filter {
    public static func any() -> Filter {
        Filter { _ in true }
    }
}

extension Filter where T: Equatable {
    public static func exact(_ value: T) -> Filter {
        Filter { $0 == value }
    }
}

extension Filter where T == String {
    public static func startsWith(_ prefix: String) -> Filter {
        Filter { $0.starts(with: prefix) }
    }
}
