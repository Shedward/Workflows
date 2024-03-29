//
//  Fields.swift
//
//
//  Created by v.maltsev on 04.09.2023.
//

import Foundation
import Prelude

public typealias NoFields = CodableVoid

extension NoFields: IssueFields {
    public static let fieldKeys: [IssueFieldKey] = []
}

public struct SummaryFields: IssueFields, Codable {
    public let summary: String
    
    public static let fieldKeys: [IssueFieldKey] = [.summary]
}

public protocol IssueFields: Decodable, Sendable {
    static var fieldKeys: [IssueFieldKey] { get }
}

extension IssueFields {
    static var fieldsDescription: String? {
        guard !fieldKeys.isEmpty else {
            return nil
        }

        return fieldKeys.map(\.rawValue).joined(separator: ",")
    }
}

public struct IssueFieldKey: Hashable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public func excluded() -> IssueFieldKey {
        IssueFieldKey(rawValue: "-\(rawValue)")
    }
}

extension IssueFieldKey: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(rawValue: value)
    }
}

public extension IssueFieldKey {
    static let all: IssueFieldKey = "*all"
    static let navigatable: IssueFieldKey = "*navigable"

    static let summary: IssueFieldKey = "summary"
}
