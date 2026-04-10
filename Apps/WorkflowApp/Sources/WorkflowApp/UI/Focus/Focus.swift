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
            Button {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                Text("Button")
            }

            if isExpanded {
                Rectangle()
                    .fill(.primary)
                    .frame(width: 100, height: 100)
            }
        }
        .padding()
        .background(.regularMaterial, in: .rect(corners: .concentric(minimum: 8)))
        .shadow(radius: 12)
    }
}

#Preview {
    Focus()
        .padding()
}
