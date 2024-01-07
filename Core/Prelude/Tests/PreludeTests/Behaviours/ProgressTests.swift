//
//  ProgressTests.swift
//
//
//  Created by Vlad Maltsev on 04.01.2024.
//

@testable import Prelude
import XCTest

final class ProgressTests: XCTestCase {
    func testProgressCalculations() {
        let p = ProgressGroup()
        let p1 = p.progress(fraction: 0.25)
        let p2 = p.group(fraction: 0.5)
        let p3 = p.progress(fraction: 0.25)
        let p21 = p2.progress(fraction: 0.5)
        let p22 = p2.progress(fraction: 0.5)
        
        XCTAssertEqual(p.state.value, 0.0)
        
        p1.state = .finished
        
        XCTAssertEqual(p.state.value, 0.25)
        
        p22.state = .finished
        
        XCTAssertEqual(p.state.value, 0.5)
        
        p21.state = .finished
        p3.state = .finished
        
        XCTAssertEqual(p.state.value, 1.0)
        
        p21.state = .failed("Failure")
        
        XCTAssertEqual(p.state.style, .failed)
        XCTAssertEqual(p.state.message, "Failure")
    }
    
    func testPublishing() throws {
        let p = ProgressGroup()
        let p2 = p.group(fraction: 0.5)
        let p22 = p2.progress(fraction: 0.5)
        
        let statePublisher = p.publisher
            .first()
        
        p22.state = .finished
        
        let state = try awaitPublisher(statePublisher)
        
        XCTAssertEqual(state, ProgressState(value: 0.25))
    }
}
