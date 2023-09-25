//
//  CommentResponse.swift
//
//
//  Created by Vladislav Maltsev on 12.08.2023.
//

import Foundation
import RestClient

struct CommentResponse: JSONDecodableBody {
    let id: String
    let parentId: String?
    let nodeId: String?
    let message: String
    let createdAt: Date
    let resolvedAt: Date?

    static func decoder() -> JSONDecoder {
        Decoders.decoder
    }

    private enum CodingKeys: CodingKey {
        case id
        case parentId
        case message
        case createdAt
        case resolvedAt
        case clientMeta
    }

    private enum ClientMetaCodingKeys: CodingKey {
        case nodeId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.parentId = try container.decodeIfPresent(String.self, forKey: .parentId)
        self.message = try container.decode(String.self, forKey: .message)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.resolvedAt = try container.decodeIfPresent(Date.self, forKey: .resolvedAt)

        let clientMetaContainer = try? container.nestedContainer(keyedBy: ClientMetaCodingKeys.self, forKey: .clientMeta)
        let nodeId = try clientMetaContainer?.decodeIfPresent(String.self, forKey: .nodeId)
        self.nodeId = nodeId
    }

    init(
        id: String,
        parentId: String?,
        nodeId: String?,
        message: String,
        createdAt: Date,
        resolvedAt: Date?
    ) {
        self.id = id
        self.parentId = parentId
        self.nodeId = nodeId
        self.message = message
        self.createdAt = createdAt
        self.resolvedAt = resolvedAt
    }
}
