//
//  TransitionPromises.swift
//
//
//  Created by Vlad Maltsev on 13.01.2024.
//

import LocalStorage

public final class TransitionPromises {

    public init() {
    }
    
    public func promise<Value: Codable>(id: String, description: String? = nil, for type: Value.Type) -> TransitionStepPromise<Value> {
        TransitionStepPromise(key: id)
    }
    
    public func promise<Value: Codable>(id: String, description: String? = nil) -> TransitionStepPromise<Value> {
        promise(id: id, description: description, for: Value.self)
    }
}
