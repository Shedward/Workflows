//
//  TransitionState+Codable.swift
//  Workflow
//
//  Created by Vlad Maltsev on 29.03.2026.
//

import Core

extension TransitionState: Codable {
    private enum CodingKeys: String, CodingKey {
        case transitionId
        case state
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        transitionId = try container.decode(TransitionID.self, forKey: .transitionId)
        state = try container.decode(State.self, forKey: .state)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(transitionId, forKey: .transitionId)
        try container.encode(state, forKey: .state)
    }
}

extension TransitionState.State: Codable {
    private enum CodingKeys: String, CodingKey {
        case type
        case waiting
        case userDescription
        case debugDescription
    }

    private enum StateType: String, Codable {
        case executing
        case waiting
        case failed
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type_ = try container.decode(StateType.self, forKey: .type)
        switch type_ {
        case .executing:
            self = .executing
        case .waiting:
            self = .waiting(try container.decode(Waiting.self, forKey: .waiting))
        case .failed:
            let userDescription = try container.decode(String.self, forKey: .userDescription)
            let debugDescription = try container.decode(String.self, forKey: .debugDescription)
            self = .failed(DeserializedError(userDescription: userDescription, debugDescription: debugDescription))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .executing:
            try container.encode(StateType.executing, forKey: .type)
        case .waiting(let waiting):
            try container.encode(StateType.waiting, forKey: .type)
            try container.encode(waiting, forKey: .waiting)
        case .failed(let error):
            try container.encode(StateType.failed, forKey: .type)
            let userDescription = (error as? DescriptiveError)?.userDescription ?? error.localizedDescription
            let debugDescription = String(reflecting: error)
            try container.encode(userDescription, forKey: .userDescription)
            try container.encode(debugDescription, forKey: .debugDescription)
        }
    }
}

private struct DeserializedError: DescriptiveError {
    let userDescription: String
    let debugDescription: String

    var errorDescription: String? { userDescription }
}
