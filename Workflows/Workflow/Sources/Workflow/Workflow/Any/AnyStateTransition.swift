//
//  AnyStateTransition.swift
//
//
//  Created by Vlad Maltsev on 06.12.2023.
//

public struct AnyStateTransition: Identifiable {
    
    private let getId: () -> String
    private let getName: () -> String
    private let call: () async throws -> Void
    
    public init<S: State>(_ wrapped: StateTransition<S>) {
        self.getId = { wrapped.id }
        self.getName = { wrapped.name }
        self.call = { try await wrapped.callAsFunction() }
    }
    
    public var id: String {
        getId()
    }
    
    public var name: String {
        getName()
    }
    
    public func callAsFunction() async throws {
        try await call()
    }
}

extension StateTransition {
    func asAny() -> AnyStateTransition {
        AnyStateTransition(self)
    }
}
