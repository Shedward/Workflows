//
//  Todo.swift
//  Core
//
//  Created by Vlad Maltsev on 22.12.2025.
//

@available(*, deprecated, message: "Need to implement")
public func implement(
    _ msg: StaticString = "",
    file: StaticString = #file,
    line: UInt = #line
) -> Never {
    fatalError("Need to implement: \(msg)", file: file, line: line)
}
