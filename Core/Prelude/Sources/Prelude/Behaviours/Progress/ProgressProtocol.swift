//
//  ProgressProtocol.swift
//
//
//  Created by Vlad Maltsev on 03.01.2024.
//

import Combine

public protocol ProgressProtocol: AnyObject {
    var parrent: ProgressProtocol? { get }
    var state: ProgressState { get }
    var publisher: AnyPublisher<ProgressState, Never> { get }
    
    func didUpdateProgress()
}

extension ProgressProtocol {
    public func didUpdateProgress() {
        parrent?.didUpdateProgress()
    }
}
