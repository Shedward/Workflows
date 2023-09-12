//
//  IssueLink+LinkType.swift
//
//
//  Created by v.maltsev on 12.09.2023.
//

extension IssueLink {

    public struct LinkType: Decodable, Sendable {
        public let id: String
        public let name: String
        public let inward: String
        public let outward: String
    }
}
