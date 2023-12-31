//
//  ProgressGroup.swift
//
//
//  Created by Vlad Maltsev on 03.01.2024.
//

import Combine
import Foundation

public class ProgressGroup: ProgressProtocol {
    public weak var parrent: ProgressProtocol?
    private var childs: [ProgressProtocol] = []
    
    public var state: ProgressState {
        childs
            .map { $0.state }
            .reduce(.initial) { $0.merge(with: $1) }
    }
    
    private var subject = CurrentValueSubject<ProgressState?, Never>(nil)
    public var publisher: AnyPublisher<ProgressState, Never> {
        subject
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    public init() {
    }
    
    init(parrent: ProgressProtocol) {
        self.parrent = parrent
    }
    
    public func didUpdateProgress() {
        subject.send(state)
        parrent?.didUpdateProgress()
    }
    
    public func progress(fraction: Float = 1.0) -> Progress {
        let fractionProgress = FractionProgress(fraction: fraction, parrent: self)
        let progress = Progress(parrent: fractionProgress)
        fractionProgress.progress = progress
        childs.append(fractionProgress)
        return progress
    }
    
    public func group(fraction: Float = 1.0) -> ProgressGroup {
        let fractionProgress = FractionProgress(fraction: fraction, parrent: self)
        let group = ProgressGroup(parrent: fractionProgress)
        fractionProgress.progress = group
        childs.append(fractionProgress)
        return group
    }
}
