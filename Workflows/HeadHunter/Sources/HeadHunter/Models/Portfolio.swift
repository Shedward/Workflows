//
//  Portfolio.swift
//
//
//  Created by v.maltsev on 04.09.2023.
//

public struct Portfolio {
    public let key: String
    public let title: String
    public let status: String

    init(key: String, title: String, status: String) {
        self.key = key
        self.title = title
        self.status = status
    }
}
