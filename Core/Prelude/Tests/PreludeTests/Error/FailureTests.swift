//
//  FailureTests.swift
//  Workflows
//
//  Created by Vladislav Maltsev on 30.07.2023.
//

import XCTest
import Prelude

final class FailureTests: XCTestCase {

    func testHierarchicalDescription() {
        let failure = Failure(
            "Second wrapped failure",
            underlyingError: Failure(
                "First wrapped failure",
                underlyingError: Failure("Original error")
            )
        )

        XCTAssertEqual(
            failure.userDescription,
            """
            Second wrapped failure
             ↪ First wrapped failure
             ↪ Original error
            """
        )
    }


    func testWrapping() throws {
        do {
            try Failure.wrap("Second wrapped failure") {
                try Failure.wrap("First wrapped failure") {
                    throw Failure("Original error")
                }
            }
        } catch {
            let failure = try XCTUnwrap(error as? Failure)
            XCTAssertEqual(
                failure.userDescription,
                """
                Second wrapped failure
                 ↪ First wrapped failure
                 ↪ Original error
                """
            )
        }
    }
}
