//
//  Fonts.swift
//  WorkflowApp
//

import SwiftUI

struct Fonts {
    let title: Font
    let subtitle: Font
    let body: Font
    let caption: Font
    let mono: Font
}

extension Fonts {
    static let system = Fonts(
        title: .headline,
        subtitle: .subheadline,
        body: .body,
        caption: .caption,
        mono: .body.monospaced()
    )
}
