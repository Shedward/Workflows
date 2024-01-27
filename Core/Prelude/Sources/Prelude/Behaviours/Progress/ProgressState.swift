//
//  ProgressState.swift
//
//
//  Created by Vlad Maltsev on 03.01.2024.
//

public struct ProgressState: Equatable {

    public enum State: Equatable {
        case notStarted
        case inProgress
        case failed
        case finished
        
        public func merge(with another: State) -> State {
            if self == another {
                return self
            }

            if self == .failed || another == .failed {
                return .failed
            }
            
            return .inProgress
        }
    }
    
    public let state: State
    public let value: Float
    public let isIndefinite: Bool
    public let messages: [String]
    
    public var message: String? {
        if messages.isEmpty {
            return nil
        }
        return messages.joined(separator: "\n")
    }
    
    public var isFinished: Bool {
        self.state == .finished
    }
    
    public init(state: State = .inProgress, value: Float = 0, isIndefinite: Bool = false, messages: [String] = []) {
        self.state = state
        self.value = value
        self.isIndefinite = isIndefinite
        self.messages = messages
    }
    
    public func merge(with another: ProgressState) -> ProgressState {
        ProgressState(
            state: state.merge(with: another.state),
            value: value + another.value,
            isIndefinite: isIndefinite || another.isIndefinite,
            messages: messages + another.messages
        )
    }
    
    public static let initial = ProgressState(state: .notStarted)
    
    public static let started = ProgressState(state: .inProgress)
    
    public static let finished = ProgressState(state: .finished, value: 1.0)
    
    public static func finished(_ message: String) -> Self {
        ProgressState(state: .finished, messages: [message])
    }

    public static func failed(_ message: String) -> Self {
        ProgressState(state: .failed, messages: [message])
    }
    
    public static func failed(_ error: Error) -> Self {
        let errorDescription = (error as? DescriptiveError)?.userDescription ?? String(describing: error)
        return failed(errorDescription)
    }
}
