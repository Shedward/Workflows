//
//  XCTExpectAsyncThrow.swift
//
//
//  Created by v.maltsev on 25.09.2023.
//

import XCTest
import Prelude

public func XCTExpectAsyncThrow(
    _ expectedError: MockFailure? = nil,
    failureReason: String? = nil,
    failingBlock: () async throws -> Void,
    file: StaticString = #file,
    line: UInt = #line
) async {
    do {
        try await failingBlock()
        XCTFail("Expected throw, but no throws occured", file: file, line: line)
    } catch {
        guard
            let expectedError,
            let mockFailure = error as? MockFailure,
            expectedError == mockFailure
        else {
            XCTFail("Throwed non matching error \(error)")
            return
        }
    }
}
