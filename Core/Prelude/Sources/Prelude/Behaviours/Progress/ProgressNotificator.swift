//
//  ProgressNotificator.swift
//
//
//  Created by Vlad Maltsev on 02.01.2024.
//

import Combine

public class ProgressNotificator {
    
    private let subject = PassthroughSubject<Progress, Never>()
    public var publisher: AnyPublisher<Progress, Never> {
        subject.eraseToAnyPublisher()
    }
    
    public func failed(_ error: Error) {
        let description = if let descriptiveError = error as? DescriptiveError {
            descriptiveError.userDescription
        } else {
            String(describing: error)
        }
        subject.send(.failed(description))
    }
    
    public func failed(_ errorMessage: String) {
        subject.send(.failed(errorMessage))
    }
    
    public func progress(_ progressValue: Progress.Value) {
        subject.send(.progress(progressValue))
    }
}
