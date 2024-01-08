//
//  Progress.swift
//
//
//  Created by Vlad Maltsev on 03.01.2024.
//

import Combine
import Foundation

public class Progress: ProgressProtocol {
    
    public weak var parrent: ProgressProtocol?
    
    public var state: ProgressState = .initial {
        didSet {
            didUpdateProgress()
        }
    }
    
    private var subject = CurrentValueSubject<ProgressState?, Never>(nil)
    public var publisher: AnyPublisher<ProgressState, Never> {
        subject
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    init(parrent: ProgressProtocol) {
        self.parrent = parrent
    }
    
    public init(state: ProgressState = .initial) {
        self.state = state
    }
    
    public func didUpdateProgress() {
        subject.send(state)
        parrent?.didUpdateProgress()
    }
}
