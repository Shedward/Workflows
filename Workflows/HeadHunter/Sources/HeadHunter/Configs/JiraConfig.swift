//
//  JiraConfig.swift
//  
//
//  Created by v.maltsev on 03.09.2023.
//

import Foundation

public struct JiraConfig: Decodable {
    public struct Filters: Decodable {
        public let currentUserPortfolio: String
    }
    
    public let host: URL
    public let filters: Filters
}
