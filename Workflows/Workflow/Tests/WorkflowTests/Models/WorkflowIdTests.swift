//
//  WorkflowIdTests.swift
//
//
//  Created by Vlad Maltsev on 22.10.2023.
//

@testable import Workflow
import XCTest

final class WorkflowIdTests: XCTestCase {
    func testUniqueIdGeneration() {
        checkUniqueUUID(name: "Simple", shouldEqualTo: "simple")
        checkUniqueUUID(name: "Some separator  and whitespaces", shouldEqualTo: "some-separator-and-whitespaces")
        checkUniqueUUID(name: "Looks/like/a/path", shouldEqualTo: "looks-like-a-path")
        checkUniqueUUID(name: "Realistic example: MOB-12345, something", shouldEqualTo: "realistic-example-mob-12345-something")
    }
    
    private func checkUniqueUUID(name: String, shouldEqualTo expected: String, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(
            WorkflowId(name: name, suffix: "suffix").rawValue,
            "\(expected)-suffix",
            file: file,
            line: line
        )
    }
}
