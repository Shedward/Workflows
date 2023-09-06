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
    public static func fieldKeys() -> [IssueFieldKey] {
        []
    }
}

public protocol IssueFields: Decodable, Sendable {
    static func fieldKeys() -> [IssueFieldKey]
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
