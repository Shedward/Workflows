//
//  KeyPathSettable.swift
//  Created by Vladislav Maltsev on 18.07.2023.
//

protocol KeyPathSettable {
}

extension KeyPathSettable {
    func set<Value>(_ keyPath: WritableKeyPath<Self, Value>, to newValue: Value) -> Self {
        var newInstance = self
        newInstance[keyPath: keyPath] = newValue
        return newInstance
    }
}
