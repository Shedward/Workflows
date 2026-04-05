//
//  WorkflowTransitionUpdatesPlugin.swift
//  workflow-server
//
//  Created by Мальцев Владислав on 31.03.2026.
//

import Foundation
import WorkflowEngine

struct WorkflowTransitionUpdatesPlugin: Plugin {
    let manifest = PluginManifest(
        name: "workflow-updates-logger",
        version: 1
    )

    var objects: [any PluginObject] {
        let profiler = TransitionTimeProfiler()

        TransitionLogger()
        profiler
        TransitionTimeControler(profiler: profiler)
    }
}
