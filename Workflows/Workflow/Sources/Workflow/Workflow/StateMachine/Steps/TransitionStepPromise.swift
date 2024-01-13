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

public actor TransitionStepPromise<Value: Codable>: AnyTransitionStepPromise {
    public let key: String
    
    private var value: Value?
    
    init(key: String) {
        self.key = key
    }
    
    public var isFullfilled: Bool {
        value != nil
    }
    
    public func fulfill(_ value: Value) {
        self.value = value
    }
    
    public func get() throws -> Value {
        guard let value else {
            throw Failure("Promise not fullfiled for \(key)")
        }
        
        return value
    }
}
