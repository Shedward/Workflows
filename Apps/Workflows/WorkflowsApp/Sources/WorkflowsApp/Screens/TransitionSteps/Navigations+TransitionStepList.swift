//
//  Navigations+TransitionStepList.swift
//  
//
//  Created by Vlad Maltsev on 07.01.2024.
//

import Workflow
import Prelude

extension Navigation {
    struct TransitionStepsList: Hashable {
        let transition: AnyWorkflowTransition
        
        init(transition: AnyWorkflowTransition) {
            self.transition = transition
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(transition.id)
        }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.transition.id == rhs.transition.id
        }
    }
    
    func showTransitionStepsList(transition: AnyWorkflowTransition) {
        path.append(TransitionStepsList(transition: transition))
    }
}
