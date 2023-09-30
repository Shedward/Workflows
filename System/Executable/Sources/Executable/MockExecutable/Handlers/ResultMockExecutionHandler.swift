//
//  ResultExecutionHandler.swift
//
//
//  Created by Vlad Maltsev on 30.09.2023.
//

import Foundation

struct ResultMockExecutionHandler: MockExecutionHandler {
    
    let filter: MockExecutionFilter
    let result: Result<ExecutableTermination, Error>
    
    func shouldAcceptExecution(_ context: MockExecutionContext) -> Bool {
        filter.matching(context)
    }
    
    func execute(in context: MockExecutionContext) async throws -> ExecutableTermination {
        try result.get()
    }
}

extension MockExecutable {
    public func addResult(filter: MockExecutionFilter, result: Result<ExecutableTermination, Error>) async {
        await addHandler(ResultMockExecutionHandler(filter: filter, result: result))
    }
    
    public func addResult(filter: MockExecutionFilter, result: Result<Void, Error>) async {
        await addHandler(ResultMockExecutionHandler(filter: filter, result: result.map { .successful }))
    }
    
    public func addSuccess(filter: MockExecutionFilter) async {
        await addResult(filter: filter, result: .success(.successful))
    }
}
