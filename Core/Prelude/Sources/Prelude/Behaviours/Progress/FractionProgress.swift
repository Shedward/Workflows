//
//  Progress.swift
//
//
//  Created by Vlad Maltsev on 03.01.2024.
//

import Combine

internal class FractionProgress: ProgressProtocol {
    
    var state: ProgressState {
        ProgressState(
            style: progress.state.style,
            value: progress.state.value * fraction,
            isIndefinite: progress.state.isIndefinite,
            message: progress.state.message
        )
    }
    
    var publisher: AnyPublisher<ProgressState, Never> {
        Empty().eraseToAnyPublisher()
    }
    
    var progress: ProgressProtocol!
    weak var parrent: ProgressProtocol?
    let fraction: Float
    
    init(fraction: Float, parrent: ProgressProtocol) {
        self.fraction = fraction
        self.parrent = parrent
    }
}
