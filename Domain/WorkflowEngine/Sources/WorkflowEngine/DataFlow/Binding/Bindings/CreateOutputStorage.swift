//
//  CreateOutputStorage.swift
//  Workflow
//
//  Created by Vlad Maltsev on 05.01.2026.
//

struct CreateOutputStorage: DataBinding {
    func output<Value>(for key: String, at output: inout Output<Value>) throws where Value : Sendable {
        output.storage = .init()
    }
}
