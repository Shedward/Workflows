//
//  MovableModifier.swift
//  WorkflowApp
//

import SwiftUI

/// Makes a view freely draggable within its parent by tracking a persistent
/// drag offset. Unlike SwiftUI's `.draggable`, this is not tied to
/// drag-and-drop transfer — it's for repositioning a view in place.
private struct MovableModifier: ViewModifier {
    @State private var offset: CGSize = .zero
    @GestureState private var translation: CGSize = .zero

    func body(content: Content) -> some View {
        content
            .offset(
                x: offset.width + translation.width,
                y: offset.height + translation.height
            )
            .gesture(
                DragGesture()
                    .updating($translation) { value, state, _ in
                        state = value.translation
                    }
                    .onEnded { value in
                        offset.width += value.translation.width
                        offset.height += value.translation.height
                    }
            )
    }
}

extension View {
    func movable() -> some View {
        modifier(MovableModifier())
    }
}
