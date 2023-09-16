//
//  View+If.swift
//
//
//  Created by v.maltsev on 16.09.2023.
//

import SwiftUI

public extension View {

    @ViewBuilder
    func iflet<Value, Content: View>(_ value: Value?, content: (Value, Self) -> Content) -> some View {
        if let value {
            content(value, self)
        } else {
            self
        }
    }

    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, content: (Self) -> Content) -> some View {
        if condition {
            content(self)
        } else {
            self
        }
    }
}
