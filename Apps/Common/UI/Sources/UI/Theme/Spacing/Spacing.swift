//
//  Spacing.swift
//
//
//  Created by v.maltsev on 16.09.2023.
//

import SwiftUI

public enum RelativeSpacing: Int {
    case d4 = 4
    case d3 = 3
    case d2 = 2
    case d1 = 1
    case same = 0
    case u1 = -1
    case u2 = -2
    case u3 = -3
    case u4 = -4
}

public struct Spacing {
    public let value: CGFloat

    static let step: CGFloat = 4

    public static let s0 = Spacing(value: 18)
    public static let s1 = s0.relative(.d1)
    public static let s2 = s0.relative(.d2)
    public static let s3 = s0.relative(.d3)
    public static let s4 = s0.relative(.d4)

    static let minimal = Spacing(value: 4)

    public func relative(_ relative: RelativeSpacing) -> Spacing {
        let nextValue = value - Spacing.step * CGFloat(relative.rawValue)
        return Spacing(value: max(nextValue, Spacing.minimal.value))
    }
}

public extension CGFloat {
    static let s0: CGFloat = Spacing.s0.value
    static let s1: CGFloat = Spacing.s1.value
    static let s2: CGFloat = Spacing.s2.value
    static let s3: CGFloat = Spacing.s3.value
    static let s4: CGFloat = Spacing.s4.value
}
