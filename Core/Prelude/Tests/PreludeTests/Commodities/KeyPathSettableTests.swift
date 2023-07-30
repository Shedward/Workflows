//
//  KeyPathSettableTests.swift
//  Workflows
//
//  Created by Vladislav Maltsev on 30.07.2023.
//

import XCTest
import Prelude

final class KeyPathSettableTests: XCTestCase {
    private struct TestStruct: KeyPathSettable, Equatable {
        var testString: String
        var testInt: Int
        var testBool: Bool
    }

    func testSetters() {
        let initialValue = TestStruct(
            testString: "String",
            testInt: 2,
            testBool: true
        )

        let resultValue = initialValue
            .set(\.testInt, to: 3)
            .set(\.testString, to: "AnotherString")

        XCTAssertEqual(
            resultValue,
            TestStruct(
                testString: "AnotherString",
                testInt: 3,
                testBool: true
            )
        )
    }
}
