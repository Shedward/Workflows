//
//  Transition.swift
//
//
//  Created by Vlad Maltsev on 03.12.2023.
//

import Prelude

public protocol Transition: Identifiable, CustomStringConvertible {
    associatedtype S: State
    
    var id: String { get }
    var name: String { get }
    
    var steps: TransitionSteps<S> { get }
}

extension Transition {
    public var description: String {
        "\(type(of: self))(id: \(id), name: \(name))"
    }
}

public class AnyTransition<S: State>: Transition {
    
    private let getId: () -> String
    private let getName: () -> String
    private let getSteps: () -> TransitionSteps<S>
    
    public var id: String {
        getId()
    }
    
    public var name: String {
        getName()
    }
    
    public init<Wrapped: Transition>(_ wrapped: Wrapped) where Wrapped.S == S {
        self.getId = { wrapped.id }
        self.getName = { wrapped.name }
        self.getSteps = { wrapped.steps }
    }
    
    public var steps: TransitionSteps<S> {
        getSteps()
    }
}

extension Transition {
    public func toAny() -> AnyTransition<S> {
        AnyTransition(self)
    }
}
