//
//  Optional+Zip.swift
//
//
//  Created by Vlad Maltsev on 04.01.2024.
//

extension Optional {
    
    public func joined(with another: Self, by join: (Wrapped, Wrapped) -> Wrapped) -> Wrapped? {
        switch (self, another) {
        case (nil, nil):
            nil
        case (.some(let lhs), nil):
            lhs
        case (nil, .some(let rhs)):
            rhs
        case (.some(let lhs), .some(let rhs)):
            join(lhs, rhs)
        }
    }
}
