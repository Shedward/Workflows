//
//  Comment.swift
//
//
//  Created by Vladislav Maltsev on 12.08.2023.
//

public struct Comment {
    private let client: FigmaClient

    public let id: String
    public let parentId: String?
    public let nodeId: String?
    public let message: String

    init(response: CommentResponse, client: FigmaClient) {
        self.client = client
        self.id = response.id
        self.nodeId = response.nodeId
        self.parentId = response.parentId
        self.message = response.message
    }
}
