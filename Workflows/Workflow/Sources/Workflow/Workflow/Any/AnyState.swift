//
//  AnyState.swift
//
//
//  Created by Vlad Maltsev on 10.12.2023.
//

public struct AnyState {
    public let id: String
    public let name: String
    public let transitions: [AnyStateTransition]
    
    init(id: String, name: String, transitions: [AnyStateTransition]) {
        self.id = id
        self.name = name
        self.transitions = transitions
    }
}
