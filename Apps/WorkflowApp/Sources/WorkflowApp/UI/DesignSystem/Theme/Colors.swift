//
//  Colors.swift
//  WorkflowApp
//

import SwiftUI

struct ColorSet {
    let primary: Color
    let secondary: Color
    let tertiary: Color
}

struct Colors {
    let content: ColorSet
    let background: ColorSet
    let accent: Color
    let positive: Color
    let negative: Color
    let warning: Color
}

extension Colors {
    static let system = Colors(
        content: ColorSet(
            primary: Color(.labelColor),
            secondary: Color(.secondaryLabelColor),
            tertiary: Color(.tertiaryLabelColor)
        ),
        background: ColorSet(
            primary: Color(.textBackgroundColor),
            secondary: Color(.controlBackgroundColor),
            tertiary: Color(.windowBackgroundColor)
        ),
        accent: Color.accentColor,
        positive: Color(.systemGreen),
        negative: Color(.systemRed),
        warning: Color(.systemOrange)
    )
}
