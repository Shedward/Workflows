//
//  BottomToolbar.swift
//
//
//  Created by Vlad Maltsev on 08.12.2023.
//

import SwiftUI

public enum BottomToolbarLayout {
    public static let heigth: CGFloat = 20
}

public struct BottomToolbar<Content: View>: View {
    
    public let content: () -> Content
    
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        HStack {
            content()
        }
        .buttonStyle(.accessoryBar)
        .spacedPadding()
        .padding(.top, 12)
        .spacing()
        .backgroundColor(\.background.secondary)
        .mask {
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .black, location: 1)
                ],
                startPoint: .topLeading,
                endPoint: .init(x: 0, y: 0.35)
            )
        }
    }
}
