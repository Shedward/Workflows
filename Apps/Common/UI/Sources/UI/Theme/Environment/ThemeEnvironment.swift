//
//  ThemeEnvironment.swift
//
//
//  Created by v.maltsev on 16.09.2023.
//

import SwiftUI

struct ThemeEnvironmentKey: EnvironmentKey {
    static var defaultValue = Theme.system
}

extension EnvironmentValues {
    public var theme: Theme {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
}

extension View {
    public func theme(_ theme: Theme) -> some View {
        environment(\.theme, theme)
    }
}
