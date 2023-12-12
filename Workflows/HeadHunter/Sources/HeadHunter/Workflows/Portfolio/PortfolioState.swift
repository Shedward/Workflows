//
//  PortfolioState.swift
//
//
//  Created by Vlad Maltsev on 06.12.2023.
//

import Workflow
import Jira

public enum PortfolioState: State {
    
    case toDo(ToDo)
    case estimation(Estimation)
    case inProgress(InProgress)
    case finished
    
    public typealias Dependencies = ()
    
    public var description: StateDescription<PortfolioState> {
        switch self {
        case .toDo(let todo):
            StateDescription(id: "Portfolio.ToDo", name: "Сделать") {
                StartEstimation(todo: todo)
                Delete()
            }
        case .estimation(let estimation):
            StateDescription(id: "Portfolio.Estimation", name: "Оценка") {
                FinishEstimation(estimation: estimation)
                BackToToDo(taskId: estimation.taskId)
                Delete()
            }
        case .inProgress(let inProgress):
            StateDescription(id: "Portfolio.InProgress", name: "В работе") {
                BackToToDo(taskId: inProgress.taskId)
                Delete()
            }
        case .finished:
            StateDescription(id: "Portfolio.Finished", name: "Завершена") {
                Delete()
            }
        }
    }
}

extension PortfolioState {

    public struct ToDo: Codable {
        public let taskId: String
        
        public init(taskId: String) {
            self.taskId = taskId
        }
    }
    
    public struct Estimation: Codable {
        public let taskId: String
        public let decompositionUrl: String
        
        public init(taskId: String, decompositionUrl: String) {
            self.taskId = taskId
            self.decompositionUrl = decompositionUrl
        }
    }
    
    public struct InProgress: Codable {
        public let taskId: String
        public let branchName: String
        
        public init(taskId: String, branchName: String) {
            self.taskId = taskId
            self.branchName = branchName
        }
    }
}
