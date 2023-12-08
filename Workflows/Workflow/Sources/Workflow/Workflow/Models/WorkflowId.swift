//
//  WorkflowId.swift
//
//
//  Created by Vlad Maltsev on 07.10.2023.
//

import Foundation

public struct WorkflowId: Codable {
    let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init(name: String, suffix: String? = nil) {
        let encodedName = name
            .components(separatedBy: .alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: "-")
            .lowercased()
        if let suffix {
            self.rawValue = "\(encodedName)-\(suffix)"
        } else {
            self.rawValue = encodedName
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.rawValue = try container.decode(String.self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}

extension WorkflowId: Hashable { }
