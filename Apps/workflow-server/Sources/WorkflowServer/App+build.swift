//
//  App+build.swift
//  workflow-server
//
//  Created by Vlad Maltsev on 08.01.2026.
//

import Configuration
import Hummingbird
import Logging

typealias AppRequestContext = BasicRequestContext

func buildApplication(reader: ConfigReader) async throws -> some ApplicationProtocol {
    let logger = {
        var logger = Logger(label: "workflow-server")
        logger.logLevel = reader.string(forKey: "log.level", as: Logger.Level.self, default: .info)
        return logger
    }()
    let router = try buildRouter()
    let app = Application(
        router: router,
        configuration: ApplicationConfiguration(reader: reader.scoped(to: "http")),
        logger: logger
    )
    return app
}


func buildRouter() throws -> Router<AppRequestContext> {
    let router = Router(context: AppRequestContext.self)
    router.addMiddleware {
        LogRequestsMiddleware(.info)
    }

    router.get("/") { _,_ in
        return "Hello!"
    }
    return router
}
