//
//  LoadingView.swift
//
//
//  Created by Vlad Maltsev on 08.12.2023.
//

import SwiftUI

public struct LoadingView: View {
    public var body: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    public init() {
    }
}

#Preview {
    LoadingView()
}
