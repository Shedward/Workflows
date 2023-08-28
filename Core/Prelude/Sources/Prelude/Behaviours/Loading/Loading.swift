//
//  Loading.swift
//
//
//  Created by v.maltsev on 26.08.2023.
//

public enum Loading<Value, Failure> {
    case loading
    case loaded(Value)
    case failure(Failure)
}

extension Loading {
    public func map<Other>(
        _ transform: (Value) -> Other
    ) -> Loading<Other, Failure> {
        switch self {
        case .loading:
            return .loading
        case .loaded(let value):
            return .loaded(transform(value))
        case .failure(let failure):
            return .failure(failure)
        }
    }
}
