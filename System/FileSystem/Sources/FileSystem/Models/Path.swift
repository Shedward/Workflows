//
//  Path.swift
//
//
//  Created by Vlad Maltsev on 24.10.2023.
//

import Foundation

public struct Path: Hashable, Codable {
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    public var string: String {
        url.path(percentEncoded: false)
    }
    
    public init(_ path: String) {
        url = URL(filePath: path).standardizedFileURL
    }
    
    public func appending(_ path: String) -> Path {
        Path(url: url.appending(path: path))
    }
    
    public func dropLast() -> Path {
        Path(url: url.deletingLastPathComponent())
    }
    
    func normalizeAsDirectory() -> Path {
        Path(url: URL(filePath: url.path(), directoryHint: .isDirectory))
    }
}

extension Path: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
}

extension Path: CustomStringConvertible {
    public var description: String {
        "Path(\(string))"
    }
}
