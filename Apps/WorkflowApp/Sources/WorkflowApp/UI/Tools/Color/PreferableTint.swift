//
//  PreferableTint.swift
//  WorkflowApp
//
//  Created by Мальцев Владислав on 16.04.2026.
//

import SwiftUI

private struct PreferableTintKey: PreferenceKey {
    static let defaultValue: Color? = nil

    static func reduce(value: inout Color?, nextValue: () -> Color?) {
        if let next = nextValue() {
            value = next
        }
    }
}

extension View {
    func preferableTint(_ color: Color?) -> some View {
        preference(key: PreferableTintKey.self, value: color)
    }

    func onPreferableTintChange(_ action: @escaping (Color?) -> Void) -> some View {
        onPreferenceChange(PreferableTintKey.self, perform: action)
    }
}
