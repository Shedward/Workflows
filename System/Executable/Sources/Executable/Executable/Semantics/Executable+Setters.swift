//
//  Executable+Setters.swift
//
//
//  Created by Vlad Maltsev on 30.09.2023.
//

import Foundation

extension Executable {
    public func workingDirectory(_ workingDirectory: URL?) -> Self {
        var executable = self
        executable.workingDirectory = workingDirectory
        return executable
    }
    
    public func workingDirectory(_ filePath: String?) -> Self {
        var executable = self
        executable.workingDirectory = filePath.map { URL(filePath: $0) }
        return executable
    }
    
    public func environmentValue(_ value: String, for key: String) -> Self {
        var executable = self
        executable.environment[key] = value
        return executable
    }
    
    public func arguments(_ arguments: [String]) -> Self {
        var executable = self
        executable.arguments = arguments
        return executable
    }
    
    public func appendingArguments(_ arguments: String...) -> Self {
        appendingArguments(arguments)
    }
    
    public func appendingArguments(_ arguments: [String]) -> Self {
        var executable = self
        executable.arguments += arguments
        return executable
    }
}
