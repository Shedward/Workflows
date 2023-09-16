//
//  ColorToken.swift
//
//
//  Created by v.maltsev on 16.09.2023.
//

import SwiftUI

public typealias ColorToken = KeyPath<Colors, Color>

extension Theme {
    public func color(for token: ColorToken) -> Color {
        colors[keyPath: token]
    }
}
