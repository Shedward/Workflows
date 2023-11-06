//
//  ArrayBuilderTests.swift
//
//
//  Created by Vlad Maltsev on 06.11.2023.
//

import Prelude
import XCTest

public final class ArrayBuilderTests: XCTestCase {
    let alwaysFalse = false
    let alwaysTrue = true
    
    func testEmpty() {
        XCTAssertEqual(
            [],
            Array<Int> { }
        )
    }
    
    func testLinear() {
        XCTAssertEqual(
            [1, 2, 3],
            .init {
                1
                2
                3
            }
        )
    }
    
    func testBranching() {
        XCTAssertEqual(
            [1, 2, 4, 5],
            .init {
                1
                2
                if alwaysFalse {
                    3
                }
                4
                if alwaysTrue {
                    5
                } else {
                    6
                }
            }
        )
    }
    
    func testAvailable() {
        XCTAssertEqual(
            [1, 2, 4],
            .init {
                1
                if #available(*) {
                    2
                } else {
                    3
                }
                4
            }
        )
    }
    
    func testCycles() {
        XCTAssertEqual(
            [1, 2, 3, 4],
            .init {
                for i in 1...4 {
                    i
                }
            }
        )
    }
}
