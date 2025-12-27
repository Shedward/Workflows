//
//  main.swift
//  workflow-cli
//
//  Created by Vlad Maltsev on 24.12.2025.
//

import Core
import Workflow

struct Напечатать_сообщение: Action {
    func run() async throws {
        print("Print action")
    }
}

struct Проверочный_флоу: Workflow {
    enum State: String, WorkflowState {
        case создан
        case в_процессе
        case завершен
    }

    var transitions: [Transition<State>] {
        from(.создан) {
            Напечатать_сообщение().to(.в_процессе)
        }
    }
}

