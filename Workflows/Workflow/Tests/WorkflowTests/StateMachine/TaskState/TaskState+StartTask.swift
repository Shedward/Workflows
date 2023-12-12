//
//  TaskState+StartTask.swift
//
//
//  Created by Vlad Maltsev on 03.12.2023.
//

import Workflow

extension TaskState {

    struct StartTask: Transition {
        
        let todo: ToDo
        
        let id = "StartTask"
        let name = "Начать задачу"
        
        func callAsFunction(_ stateMachine: StateMachine<TaskState>) async throws {
            try stateMachine.move(
                to: .inProgress(TaskState.InProgress(id: todo.id, branch: todo.id))
            )
        }
    }
}
