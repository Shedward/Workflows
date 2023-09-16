//
//  SpacingEnvironment.swift
//  
//
//  Created by v.maltsev on 16.09.2023.
//

import SwiftUI

struct SpacingEnvironmentKey: EnvironmentKey {
    static var defaultValue = Spacing.s0
}

extension EnvironmentValues {
    public var spacing: Spacing {
        get { self[SpacingEnvironmentKey.self] }
        set { self[SpacingEnvironmentKey.self] = newValue }
    }
}

extension View {
    public func spacing(_ spacing: Spacing) -> some View {
        environment(\.spacing, spacing)
    }
}
