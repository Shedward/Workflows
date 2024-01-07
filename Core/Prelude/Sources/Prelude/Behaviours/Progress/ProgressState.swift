//
//  ProgressState.swift
//
//
//  Created by Vlad Maltsev on 03.01.2024.
//

public struct ProgressState: Equatable {

    public enum Style {
        case normal
        case failed
        
        public func merge(with another: Style) -> Style {
            if self == .failed || another == .failed {
                .failed
            } else {
                .normal
            }
        }
    }
    
    public let style: Style
    public let value: Float
    public let isIndefinite: Bool
    public let message: String?
    
    public init(style: Style = .normal, value: Float = 0, isIndefinite: Bool = false, message: String? = nil) {
        self.style = style
        self.value = value
        self.isIndefinite = isIndefinite
        self.message = message
    }
    
    public func merge(with another: ProgressState) -> ProgressState {
        ProgressState(
            style: style.merge(with: another.style),
            value: value + another.value,
            isIndefinite: isIndefinite || another.isIndefinite,
            message: message.joined(with: another.message) { [$0, $1].joined(separator: "\n") }
        )
    }
    
    public static let initial = ProgressState(value: 0.0)
    
    public static let finished = ProgressState(value: 1.0)

    public static func failed(_ message: String) -> Self {
        ProgressState(style: .failed, message: message)
    }
    
    public static func failed(_ error: Error) -> Self {
        let errorDescription = (error as? DescriptiveError)?.userDescription ?? String(describing: error)
        return failed(errorDescription)
    }
}
