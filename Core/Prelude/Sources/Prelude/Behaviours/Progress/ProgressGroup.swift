//
//  ProgressGroup.swift
//
//
//  Created by Vlad Maltsev on 03.01.2024.
//

import Combine

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
    
    public func addChildProgress(_ progress: Progress, fraction: Float = 1.0) {
        let fractionProgress = FractionProgress(fraction: fraction, parrent: self)
        fractionProgress.progress = progress
        childs.append(fractionProgress)
    }
    
    public func group(fraction: Float = 1.0) -> ProgressGroup {
        let fractionProgress = FractionProgress(fraction: fraction, parrent: self)
        let group = ProgressGroup(parrent: fractionProgress)
        fractionProgress.progress = group
        childs.append(fractionProgress)
        return group
    }
    
    public func addCGroupProgress(_ progress: ProgressGroup, fraction: Float = 1.0) {
        let fractionProgress = FractionProgress(fraction: fraction, parrent: self)
        fractionProgress.progress = progress
        childs.append(fractionProgress)
    }
}
