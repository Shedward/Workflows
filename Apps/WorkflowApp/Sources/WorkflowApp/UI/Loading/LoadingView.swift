//
//  LoadingView.swift
//  WorkflowApp
//

import SwiftUI

struct LoadingView<Value, Content: View>: View {
    let loading: Loading<Value>
    let content: (Value) -> Content

    var body: some View {
        switch loading.state {
            case .idle:
                EmptyView()
            case .loading:
                ProgressView()
                    .controlSize(.small)
                    .frame(maxWidth: .infinity)
                    .padding()
            case .loaded(let value):
                content(value)
            case .failed(let error):
                DrawerMessage(text: error.localizedDescription)
        }
    }

    init(_ loading: Loading<Value>, @ViewBuilder content: @escaping (Value) -> Content) {
        self.loading = loading
        self.content = content
    }
}
