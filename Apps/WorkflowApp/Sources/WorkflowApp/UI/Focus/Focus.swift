//
//  Focus.swift
//  WorkflowApp
//
//  Created by Мальцев Владислав on 09.04.2026.
//

import SwiftUI

struct Focus: View {
    @State
    private var isExpanded: Bool = false

    var body: some View {
        VStack {
            Text("Focus")
                .themeFont(\.title)
                .themeColor(\.content.primary)
            Button {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                Text("Button")
                    .themeFont(\.body)
            }

            if isExpanded {
                Rectangle()
                    .fill(.primary)
                    .frame(width: 100, height: 100)
            }
        }
        .themePadding(\.m)
        .background(.regularMaterial, in: .rect(corners: .concentric(minimum: 8)))
        .shadow(radius: 12)
    }
}

#Preview {
    Focus()
        .padding()
}
