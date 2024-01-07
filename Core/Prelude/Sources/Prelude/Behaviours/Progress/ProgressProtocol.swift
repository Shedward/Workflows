//
//  ProgressProtocol.swift
//
//
//  Created by Vlad Maltsev on 03.01.2024.
//

public protocol ProgressProtocol: AnyObject {
    var parrent: ProgressProtocol? { get }
    var state: ProgressState { get }
    
    func didUpdateProgress()
}

extension ProgressProtocol {
    public func didUpdateProgress() {
        parrent?.didUpdateProgress()
    }
}
