//
//  CleanStorage.swift
//  Workflow
//
//  Created by Vlad Maltsev on 05.01.2026.
//

struct CleanStorage: DataBinding {
    func input<Value>(for key: String, at input: inout Input<Value>) throws where Value : Sendable {
        input.storage = nil
    }

    func output<Value>(for key: String, at output: inout Output<Value>) throws where Value : Sendable {
        output.storage = nil
    }

    func dependency<Value>(for key: String, at dependency: inout Dependency<Value>) throws where Value : Sendable {
        dependency.storage = nil
    }
}
