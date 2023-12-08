//
//  NewWorkflowService.swift
//
//
//  Created by Vlad Maltsev on 07.12.2023.
//

import Prelude

public final class NewWorkflowService {
    
    private var providers: [NewWorkflowProvider]
    
    public init(providers: [NewWorkflowProvider]) {
        self.providers = providers
    }
    
    public init(@ArrayBuilder<NewWorkflowProvider> builder: () ->  [NewWorkflowProvider]) {
        self.providers = builder()
    }
    
    func workflows() async throws -> [NewWorkflowSection] {
        var sections: [NewWorkflowSection] = []
        
        for provider in providers {
            sections.append(
                NewWorkflowSection(
                    id: provider.id,
                    title: provider.name,
                    workflows: try await Result.async { try await provider.workflows() }
                )
            )
        }
        
        return sections
    }
}
