//
//  OutputMockExecutionHandler.swift
//
//
//  Created by Vlad Maltsev on 01.10.2023.
//

import Foundation
import Prelude

struct OutputMockExecutionHandler: MockExecutionHandler {
    
    let filter: MockExecutionFilter
    let termination: ExecutableTermination
    let result: Result<Data, Error>
    
    func shouldAcceptExecution(_ context: MockExecutionContext) -> Bool {
        filter.matching(context)
    }
    
    func execute(in context: MockExecutionContext) async throws -> ExecutableTermination {
        let data = try result.get()
        guard let output = context.pipes.output as? Pipe else {
            throw Failure("Expected output pipe for OutputMockExecutionHandler")
        }
        
        try output.fileHandleForWriting.write(contentsOf: data)
        return termination
    }
}

extension MockExecutable {
    public func addDataOutput(filter: MockExecutionFilter, termination: ExecutableTermination = .successful, result: Result<Data, Error>) async {
        await addHandler(OutputMockExecutionHandler(filter: filter, termination: termination, result: result))
    }
    
    public func addOutput(
        filter: MockExecutionFilter,
        termination: ExecutableTermination = .successful,
        encoding: String.Encoding = .utf8,
        result: Result<String, Error>
    ) async {
        let dataResult = result.flatMap { string in
            if let data = string.data(using: encoding) {
                return .success(data)
            } else {
                return .failure(Failure("Failed to encode string \(string) to data"))
            }
        }
        await addDataOutput(filter: filter, termination: termination, result: dataResult)
    }
}
