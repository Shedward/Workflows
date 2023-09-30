//
//  XCTExpectAsyncFailure.swift
//
//
//  Created by v.maltsev on 25.09.2023.
//

import XCTest
import Prelude

public func XCTExpectThrow(
    _ expectedError: MockFailure? = nil,
    failureReason: String? = nil,
    failingBlock: () throws -> Void,
    file: StaticString = #file,
    line: UInt = #line
) {
    do {
        try failingBlock()
        XCTFail("Expected throw, but no throws occured", file: file, line: line)
    } catch {
        if expectedError == nil {
            return
        }

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
