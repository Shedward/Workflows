//
//  MockExecutionHandlersStorage.swift
//
//
//  Created by Vlad Maltsev on 30.09.2023.
//

import Prelude

actor MockExecutionHandlersStorage {
    private let label: StaticString
    private var handlers: [MockExecutionHandler] = []
    
    init(label: StaticString) {
        self.label = label
    }
    
    func executeHandler(in context: MockExecutionContext) async throws -> ExecutableTermination {
        var firstHandler: MockExecutionHandler?
        handlers = handlers.filter { handler in
            if handler.shouldAcceptExecution(context) {
                firstHandler = handler
                return false
            }
            return true
        }
        
        guard let firstHandler else {
            throw Failure("MockExecutable(\(label)) have no handler for context \(context)")
        }
        
        return try await firstHandler.execute(in: context)
    }
    
    func addHandler(_ handler: MockExecutionHandler) {
        handlers.append(handler)
    }
}
