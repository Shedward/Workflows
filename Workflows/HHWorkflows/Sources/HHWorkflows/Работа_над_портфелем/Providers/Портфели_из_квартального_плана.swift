//
//  Портфели_из_квартального_плана.swift
//  HHWorkflows
//
//  Created by Мальцев Владислав on 04.04.2026.
//

import WorkflowEngine

@DataBindable
struct Портфели_из_квартального_плана: WorkflowStartProvider {
    func starting() async throws -> [WorkflowStart] {
        [
            WorkflowStart(title: "PORTFOLIO-23325: navigation bar v9")
                .input("portfolioId", to: "PORTFOLIO-23325"),
            WorkflowStart(title: "PORTFOLIO-23333: доработки снапшот-тестов")
                .input("portfolioId", to: "PORTFOLIO-23333"),
            WorkflowStart(title: "PORTFOLIO-20000: баги компонентов")
                .input("portfolioId", to: "PORTFOLIO-20000")
        ]
    }
}
