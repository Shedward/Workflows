//
//  Path.swift
//
//
//  Created by Vlad Maltsev on 24.10.2023.
//

import Foundation

public struct Path: Hashable {
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    public var string: String {
        url.path()
    }
    
    public init(_ path: String) {
        url = URL(filePath: path)
    }
    
    public func appending(_ path: String) -> Path {
        Path(url: url.appending(path: path))
    }
    
    public func dropLast() -> Path {
        Path(url: url.deletingLastPathComponent())
    }
}

extension Path: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
}
