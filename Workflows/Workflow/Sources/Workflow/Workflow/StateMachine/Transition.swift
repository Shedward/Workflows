//
//  Transition.swift
//
//
//  Created by Vlad Maltsev on 03.12.2023.
//

public protocol Transition: Identifiable, CustomStringConvertible {
    associatedtype S: State
    
    var id: String { get }
    var name: String { get }
    
    func callAsFunction(_ stateMachine: StateMachine<S>) async throws
}

extension Transition {
    public var description: String {
        "\(type(of: self))(id: \(id), name: \(name))"
    }
}

public class AnyTransition<S: State>: Transition {
    
    private let getId: () -> String
    private let getName: () -> String
    private let call: (StateMachine<S>) async throws -> Void
    
    public var id: String {
        getId()
    }
    
    public var name: String {
        getName()
    }
    
    public init<Wrapped: Transition>(_ wrapped: Wrapped) where Wrapped.S == S {
        self.getId = { wrapped.id }
        self.getName = { wrapped.name }
        self.call = wrapped.callAsFunction
    }
    
    public func callAsFunction(_ stateMachine: StateMachine<S>) async throws {
        try await call(stateMachine)
    }
}

extension Transition {
    public func toAny() -> AnyTransition<S> {
        AnyTransition(self)
    }
}
