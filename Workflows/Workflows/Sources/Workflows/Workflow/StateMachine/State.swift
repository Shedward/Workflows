//
//  State.swift
//
//
//  Created by Vlad Maltsev on 03.12.2023.
//

public protocol State: Codable {
    associatedtype Dependencies
    
    var description: StateDescription<Self> { get }
}
