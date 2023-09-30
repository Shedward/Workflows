//
//  MockExecutionHanlder.swift
//
//
//  Created by Vlad Maltsev on 01.10.2023.
//

protocol MockExecutionHandler {
    
    func shouldAcceptExecution(_ context: MockExecutionContext) -> Bool
    func execute(in context: MockExecutionContext) async throws -> ExecutableTermination
}
