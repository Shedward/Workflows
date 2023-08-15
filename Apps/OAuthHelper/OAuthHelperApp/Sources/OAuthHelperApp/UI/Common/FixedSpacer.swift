//
//  FixedSpacer.swift
//
//
//  Created by v.maltsev on 14.08.2023.
//

import SwiftUI

struct FixedSpacer: View {
    let width: CGFloat
    let height: CGFloat

    init(width: CGFloat = 0, height: CGFloat = 0) {
        self.width = width
        self.height = height
    }

    init(_ length: CGFloat) {
        self.init(width: length, height: length)
    }

    var body: some View {
        Spacer()
            .frame(width: width, height: height)
    }
}
