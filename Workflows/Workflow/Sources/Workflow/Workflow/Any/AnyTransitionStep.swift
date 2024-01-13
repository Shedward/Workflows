//
//  AnyTransitionStep.swift
//
//
//  Created by Vlad Maltsev on 07.01.2024.
//

import Prelude

public struct AnyTransitionStep: Identifiable {
    public let id: String
    public let name: String?
    public let progress: ProgressProtocol
    public let action: () async throws -> Void
    
    public init(id: String, name: String?, progress: ProgressProtocol, action: @escaping () async throws -> Void) {
        self.id = id
        self.name = name
        self.progress = progress
        self.action = action
    }
}
