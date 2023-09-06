//
//  Moba.swift
//
//
//  Created by v.maltsev on 06.09.2023.
//

public struct Task {
    public let key: String
    public let title: String

    public let portfolio: Portfolio?

    init(key: String, title: String, portfolio: Portfolio?) {
        self.key = key
        self.title = title
        self.portfolio = portfolio
    }
}
