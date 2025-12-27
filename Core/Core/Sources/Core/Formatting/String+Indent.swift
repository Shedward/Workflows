//
//  String+Indent.swift
//  Core
//
//  Created by Vlad Maltsev on 24.12.2025.
//

extension String {
    public func indented(by count: Int = 1, step: Int = 2) -> String {
        let spaces = max(0, count * step)
        guard spaces > 0, !isEmpty else { return self }

        let hasTrailingNewline = last?.isNewline ?? false

        let prefix = String(repeating: " ", count: spaces)

        let indented = split(separator: "\n")
            .map { $0.isEmpty ? $0 : prefix + $0 }
            .joined(separator: "\n")

        return hasTrailingNewline ? indented + "\n" : indented
    }
}
