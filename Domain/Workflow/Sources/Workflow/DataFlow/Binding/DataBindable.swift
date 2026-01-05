//
//  Activity.swift
//  Workflow
//
//  Created by Vlad Maltsev on 03.01.2026.
//

public protocol DataBindable: Sendable {
    mutating func bind(_ bind: inout any DataBinding) throws
}
