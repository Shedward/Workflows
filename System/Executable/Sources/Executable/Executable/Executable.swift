//
//  Executable.swift
//
//
//  Created by Vlad Maltsev on 30.09.2023.
//

import Foundation

public protocol Executable {
    typealias Action = () async throws -> ExecutableTermination
    
    var pipes: ExecutablePipes { get set }
    var workingDirectory: URL? { get set }
    var environment: [String: String] { get set }
    var arguments: [String] { get set }
    
    func execute() async throws -> ExecutableTermination
}
