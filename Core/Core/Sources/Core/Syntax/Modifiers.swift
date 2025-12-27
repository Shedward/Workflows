//
//  Modifiable.swift
//  Core
//
//  Created by Vlad Maltsev on 21.12.2025.
//

public protocol Modifiers {
}

extension Modifiers {

    @inlinable
    @inline(__always)
    public func with(_ modify: (inout Self) -> Void) -> Self {
        var new = self
        modify(&new)
        return new
    }
}
