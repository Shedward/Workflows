//
//  Spacing.swift
//
//
//  Created by v.maltsev on 16.09.2023.
//

import SwiftUI

public struct Spacing {
    public let value: CGFloat

    static let step: CGFloat = 6

    public static let s0 = Spacing(value: 24)
    public static let s1 = s0.down()
    public static let s2 = s1.down()
    public static let s3 = s2.down()
    public static let s4 = s3.down()

    static let minimal = Spacing(value: 4)

    public func down(_ steps: Int = 1) -> Spacing {
        let nextValue = value - Spacing.step * CGFloat(steps)
        return Spacing(value: max(nextValue, Spacing.minimal.value))
    }

    public func up(_ steps: Int = 1) -> Spacing {
        let previousValue = value + Spacing.step * CGFloat(steps)
        return Spacing(value: previousValue)
    }
}

public extension CGFloat {
    static let s0: CGFloat = Spacing.s0.value
    static let s1: CGFloat = Spacing.s1.value
    static let s2: CGFloat = Spacing.s2.value
    static let s3: CGFloat = Spacing.s3.value
    static let s4: CGFloat = Spacing.s4.value
}
