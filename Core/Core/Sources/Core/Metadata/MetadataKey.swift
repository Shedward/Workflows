//
//  MetadataKey.swift
//  Core
//
//  Created by Vlad Maltsev on 23.12.2025.
//

public protocol MetadataKey {
    associatedtype Value: Sendable
    static var defaultValue: Value { get }
}
