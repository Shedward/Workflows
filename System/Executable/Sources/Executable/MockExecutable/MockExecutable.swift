//
//  MockExecutable.swift
//
//
//  Created by Vlad Maltsev on 30.09.2023.
//

import Foundation

public struct MockExecutable: Sendable, Executable {
    
    public var arguments: [String] = []
    public var environment: [String : String] = [:]
    public var workingDirectory: URL?
    public var pipes: ExecutablePipes = .init()
    
    private let storage: MockExecutionHandlersStorage
    
    public init(label: StaticString) {
        self.storage = MockExecutionHandlersStorage(label: label)
    }
    
    public func execute() async throws -> ExecutableTermination {
        let context = MockExecutionContext(
            workingDirectory: workingDirectory?.path(percentEncoded: false),
            arguments: arguments,
            environment: environment,
            pipes: pipes
        )
        
        return try await storage.executeHandler(in: context)
    }
    
    func addHandler(_ handler: MockExecutionHandler) async {
        await storage.addHandler(handler)
    }
}
