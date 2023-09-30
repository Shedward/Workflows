//
//  UserTests.swift
//
//
//  Created by v.maltsev on 25.09.2023.
//

@testable import Figma
import XCTest
import TestsPrelude

final class UserTests: XCTestCase {
    func testMe() async throws {
        let mock = FigmaMock()
        let figma = Figma(mock: mock)

        await mock.setMeResponse(
            response: .success(UserResponse(id: "1", email: "mock@mock.mock", handle: "@mock_user"))
        )
        let myUser = try await figma.me()
        XCTAssertEqual(myUser.handle, "@mock_user")
    }
    
    func testMeFailure() async throws {
        let mock = FigmaMock()
        let figma = Figma(mock: mock)
        
        await mock.setMeResponse(
            response: .failure(MockFailure("Failed request"))
        )

        await XCTExpectAsyncThrow(MockFailure("Failed request")) {
            _ = try await figma.me()
        }
    }
}
