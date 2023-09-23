//
//  DictionaryBuildableTests.swift
//  Workflows
//
//  Created by Vladislav Maltsev on 30.07.2023.
//

import XCTest
import Prelude

final class DictionaryBuildableTests: XCTestCase {

    private struct TestingDictionary: DictionaryBuildable, Equatable {
        var values: [String: String] = [:]

        init(values: [String : String]) {
            self.values = values
        }
    }

    func testSetters() {
        let singleSetter = TestingDictionary().set("First", to: "FirstValue")

        XCTAssertEqual(
            singleSetter,
            TestingDictionary(values: ["First": "FirstValue"])
        )

        let doubleSetters = singleSetter
            .set("Second", to: "SecondValue")
            .set("Third", to: "ThirdValue")

        XCTAssertEqual(
            doubleSetters,
            TestingDictionary(values: [
                "First": "FirstValue",
                "Second": "SecondValue",
                "Third": "ThirdValue",
            ])
        )

        let removedSetters = doubleSetters
            .set("Second", to: nil)
        XCTAssertEqual(
            removedSetters,
            TestingDictionary(values: [
                "First": "FirstValue",
                "Third": "ThirdValue",
            ])
        )
    }

    func testMerging() {
        let firstValue = TestingDictionary(values: [
            "A": "a",
            "B": "b",
            "C": "c"
        ])

        let secondValue = TestingDictionary(values: [
            "C": "3",
            "D": "4",
            "E": "5"
        ])

        let result = firstValue.merging(with: secondValue)

        XCTAssertEqual(
            result,
            TestingDictionary(values: [
                "A": "a",
                "B": "b",
                "C": "3",
                "D": "4",
                "E": "5"
            ])
        )
    }
}
