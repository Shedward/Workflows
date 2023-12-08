//
//  FailureView.swift
//
//
//  Created by Vlad Maltsev on 08.12.2023.
//

import SwiftUI
import Prelude

public struct FailureView: View {
    
    @Environment(\.theme)
    private var theme: Theme
    
    private let title: String
    private let error: Error
    
    public var body: some View {
        ContentUnavailableView(
            title,
            systemImage: "exclamationmark.triangle",
            description: Text(errorDescription())
        )
        
    }
    
    public init(title: String, error: Error) {
        self.title = title
        self.error = error
    }
    
    public init(_ error: Error) {
        self.title = "Error"
        self.error = error
    }
    
    private func errorDescription() -> String {
        if let descriptiveError = error as? DescriptiveError {
            return descriptiveError.userDescription
        } else {
            return String(describing: error)
        }
    }
}

#Preview {
    FailureView(Failure("Loading failed, something something"))
        .frame(width: 200)
}
