//
//  TestState.swift
//
//
//  Created by Vlad Maltsev on 17.11.2023.
//

import Workflows

enum TaskState: State {
    case todo(ToDo)
    case inProgress(InProgress)
    case review(Review)
    case testing(Testing)
    case done(Done)
    
    var description: StateDescription<TaskState> {
        switch self {
        case .todo(let todo):
            StateDescription(id: "ToDo", name: "Сделать") {
                StartTask(todo: todo)
            }
        case .inProgress(let inProgress):
            StateDescription(id: "InProgress", name: "В работе") {
                SendToReview(inProgress: inProgress)
            }
        case .review(let review):
            StateDescription(id: "Review", name: "Ревью") {
                StartTesting(review: review)
            }
        case .testing(let testing):
            StateDescription(id: "Testing", name: "Тестирование") {
                FinishTesting(testing: testing)
            }
        case .done:
            StateDescription(id: "Done", name: "Готово")
        }
    }
}

extension TaskState {
    struct ToDo: Codable {
        let id: String
    }

    struct InProgress: Codable {
        let id: String
        let branch: String
    }
    
    struct Review: Codable {
        let id: String
        let branch: String
        let reviewUrl: String
    }
    
    struct Testing: Codable {
        let id: String
        let tester: String
    }
    
    struct Done: Codable {
        let id: String
    }
}
