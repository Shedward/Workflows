//
//  TransitionStep.swift
//
//
//  Created by Vlad Maltsev on 02.01.2024.
//

import Prelude
import Foundation

public struct TransitionStep {
    public let id: String
    public let name: String?
    private let action: (_ progress: Prelude.Progress) async throws -> Void
    
    public init(id: String, name: String?, _ action: @escaping (_ progressGroup: Prelude.Progress) async throws -> Void) {
        self.id = id
        self.name = name
        self.action = action
    }
    
    func callAsFunction(_ progress: Prelude.Progress) async throws {
        try await action(progress)
    }
}
