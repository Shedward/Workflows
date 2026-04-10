//
//  Spacing.swift
//  WorkflowApp
//

import SwiftUI

struct Spacing {
    let xxs: CGFloat
    let xs: CGFloat
    let s: CGFloat
    let m: CGFloat
    let l: CGFloat
    let xl: CGFloat
    let cornerRadius: CGFloat
}

extension Spacing {
    static let `default` = Spacing(
        xxs: 2,
        xs: 4,
        s: 6,
        m: 8,
        l: 12,
        xl: 16,
        cornerRadius: 8
    )
}
