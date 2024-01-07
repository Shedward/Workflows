//
//  TransitionStepPromise.swift
//
//
//  Created by Vlad Maltsev on 02.01.2024.
//

import Prelude
import LocalStorage

public protocol AnyTransitionStepPromise {
    var key: String { get }
}

public actor TransitionStepPromise<Value>: AnyTransitionStepPromise {
    public let key: String
    
    private var value: Value?
    private let storage: CodableStorage
    
    init(key: String, storage: CodableStorage) {
        self.key = key
        self.storage = storage
    }
    
    public func fullfill(_ value: Value) {
        self.value = value
    }
    
    public func get() throws -> Value {
        guard let value else {
            throw Failure("Promise not fullfiled for \(key)")
        }
        
        return value
    }
}
