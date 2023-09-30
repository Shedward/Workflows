//
//  Array+chunked.swift
//
//
//  Created by Vlad Maltsev on 30.09.2023.
//

extension Array {
    public func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
