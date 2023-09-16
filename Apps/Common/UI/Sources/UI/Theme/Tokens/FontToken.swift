//
//  FontToken.swift
//
//
//  Created by v.maltsev on 16.09.2023.
//

import SwiftUI

public typealias FontToken = KeyPath<Fonts, Font>

extension Theme {
    public func font(for token: FontToken) -> Font {
        fonts[keyPath: token]
    }
}
