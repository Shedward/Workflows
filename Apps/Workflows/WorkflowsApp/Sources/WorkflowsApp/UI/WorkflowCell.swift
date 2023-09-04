//
//  WorkflowCell.swift
//
//
//  Created by v.maltsev on 04.09.2023.
//

import SwiftUI

struct WorkflowCell: View {
    let key: String
    let icon: Image
    let name: String
    let state: String

    var body: some View {
        HStack(alignment: .top) {
            icon
                .font(.caption)
                .padding(.top, 8)
            VStack(alignment: .leading) {
                HStack {
                    Text(key)
                        .font(.caption)
                    Spacer()
                    Text(state)
                        .font(.caption)
                }
                Text(name)
                    .lineLimit(2)
                    .font(.body)
            }
        }
        .padding(4)
    }
}

#Preview {
    List {
        WorkflowCell(
            key: "PORTFOLIO-22623",
            icon: Image(systemName: "briefcase"),
            name: "Реализовать экран списка флоу",
            state: "В работе"
        )
        WorkflowCell(
            key: "PORTFOLIO-22623",
            icon: Image(systemName: "suitcase"),
            name: "Реализовать экран списка флоу",
            state: "АБ-тестирование"
        )
    }
    .listStyle(.plain)
    .frame(maxWidth: 300)
}
