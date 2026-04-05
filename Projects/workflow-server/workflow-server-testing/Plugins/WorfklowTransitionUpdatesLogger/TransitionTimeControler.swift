//
//  TransitionTimeControler.swift
//  workflow-server
//
//  Created by Мальцев Владислав on 31.03.2026.
//

import Rest
import API
import WorkflowEngine
import WorkflowServer
import Hummingbird

final class TransitionTimeControler: PluginController, @unchecked Sendable {
    private var profiler: TransitionTimeProfiler

    var endpoints: RouteCollection<AppRequestContext> {
        RouteCollection()
            .on(GetTransitionTimeReport.self, use: getReport)
    }

    init(profiler: TransitionTimeProfiler) {
        self.profiler = profiler
    }

    private func getReport(request: Request, body: EmptyBody, context: Context) async -> ListBody<GetTransitionTimeReport.TimeRecord> {
        let records = profiler.measurements.map { key, value in
            GetTransitionTimeReport.TimeRecord(
                transitionId: key,
                measurements: value.map { Double($0) }
            )
        }
        return ListBody(items: records)
    }
}

public struct GetTransitionTimeReport: WorkflowApi {
    public typealias ResponseBody = ListBody<GetTransitionTimeReport.TimeRecord>

    public struct TimeRecord: JSONBody {
        let transitionId: WorkflowEngine.TransitionID
        let measurements: [Double]
    }

    public static let method = Method.get
    public static let path = "/transitionTime/report"
}
