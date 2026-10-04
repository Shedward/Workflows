//
//  Fonts.swift
//  WorkflowApp
//

import SwiftUI

struct Fonts {
    let large: Font
    let headline: Font
    let subtitle: Font
    let body: Font
    let caption: Font
    let mono: Font
}

extension Fonts {
    static let system = Fonts(
        large: .largeTitle,
        headline: .headline,
        subtitle: .subheadline,
        body: .body,
        caption: .caption,
        mono: .body.monospaced()
    )
}
