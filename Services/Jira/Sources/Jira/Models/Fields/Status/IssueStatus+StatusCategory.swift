//
//  IssueStatus+StatusCategory.swift
//
//
//  Created by v.maltsev on 12.09.2023.
//

import Foundation

extension IssueStatus {

    public struct StatusCategory: Decodable, Sendable {
        public let id: Int
        public let key: String
        public let colorName: String?
        public let name: String
    }
}
