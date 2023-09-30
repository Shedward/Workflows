//
//  CommentsTests.swift
//
//
//  Created by v.maltsev on 25.09.2023.
//

@testable import Figma
import XCTest
import TestsPrelude

final class CommentsTests: XCTestCase {
    func testComments() async throws {
        let mock = FigmaMock()
        let figma = Figma(mock: mock)

        await mock.addCommentsResponse(
            fileKey: "mock_file",
            response: .success(
                CommentsListResponse(
                    comments: [
                        CommentResponse(
                            id: "1",
                            parentId: nil,
                            nodeId: "node1",
                            message: "Mock comment message",
                            createdAt: Date(),
                            resolvedAt: nil
                        ),
                        CommentResponse(
                            id: "2",
                            parentId: nil,
                            nodeId: "node1",
                            message: "Second mock comment message",
                            createdAt: Date(),
                            resolvedAt: nil
                        )
                    ]
                )
            )
        )

        let comments = try await figma.file(key: "mock_file").comments()
        XCTAssertEqual(comments.count, 2)
        let firstComment = try XCTUnwrap(comments.first)
        XCTAssertEqual(firstComment.message, "Mock comment message")
    }
    

    func testCommentsFailure() async throws {
        let mock = FigmaMock()
        let figma = Figma(mock: mock)
        
        await mock.addCommentsResponse(
            fileKey: "mock_file",
            response: .failure(MockFailure("Failed request"))
        )

        await XCTExpectAsyncThrow(MockFailure("Failed request")) {
            _ = try await figma.file(key: "mock_file").comments()
        }
    }
}
