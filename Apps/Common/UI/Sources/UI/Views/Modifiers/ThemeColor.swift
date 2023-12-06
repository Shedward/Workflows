//
//  ThemeColor.swift
//  
//
//  Created by v.maltsev on 16.09.2023.
//


import SwiftUI

public struct ThemeColor: ShapeStyle {

    public let colorToken: ColorToken

    public init(_ colorToken: ColorToken) {
        self.colorToken = colorToken
    }

    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        environment.theme.color(for: colorToken)
    }
}
