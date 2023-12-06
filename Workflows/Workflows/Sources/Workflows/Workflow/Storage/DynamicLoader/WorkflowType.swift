//
//  WorkflowType.swift
//  
//
//  Created by Vlad Maltsev on 06.12.2023.
//

public struct WorkflowType: Codable, Hashable, ExpressibleByStringLiteral, CustomStringConvertible {

    public let id: String
    
    public init(_ id: String) {
        self.id = id
    }
    
    public init<S: State>(_ type: S.Type) {
        self.id = String(describing: type)
    }
    
    public init(stringLiteral value: StringLiteralType) {
        self.id = value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.id = try container.decode(String.self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.id)
    }
    
    public var description: String {
        id
    }
}
