//
//  Dataflow.swift
//  Workflow
//
//  Created by Vlad Maltsev on 04.01.2026.
//

public protocol DataBinding {
    mutating func input<Value: Sendable>(for key: String, at input: inout Input<Value>) throws
    mutating func output<Value: Sendable>(for key: String, at output: inout Output<Value>) throws
    mutating func dependency<Value: Sendable>(for key: String, at dependency: inout Dependency<Value>) throws
    mutating func ask<Value: Sendable>(for key: String, at ask: inout Ask<Value>) throws
}

public extension DataBinding {
    mutating func input<Value: Sendable>(for key: String, at input: inout Input<Value>) {
    }

    mutating func output<Value: Sendable>(for key: String, at output: inout Output<Value>) {
    }

    mutating func dependency<Value: Sendable>(for key: String, at dependency: inout Dependency<Value>) {
    }

    mutating func ask<Value: Sendable>(for key: String, at ask: inout Ask<Value>) {
    }
}
