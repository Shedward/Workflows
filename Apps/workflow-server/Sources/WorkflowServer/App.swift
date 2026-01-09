// The Swift Programming Language
// https://docs.swift.org/swift-book
//
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import Configuration
import Hummingbird
import Logging
import WorkflowEngine

typealias AppRequestContext = BasicRequestContext

public struct App {

    public let workflows: Workflows

    public init(workflows: Workflows) {
        self.workflows = workflows
    }

    public func main() async throws {
        let reader = try await ConfigReader(providers: [
            EnvironmentVariablesProvider(),
            EnvironmentVariablesProvider(environmentFilePath: ".env", allowMissing: true),
            InMemoryProvider(values: [
                "http.serverName": "workflow-server"
            ])
        ])
        let app = try await buildApplication(reader: reader)
        try await app.runService()
    }

    func buildApplication(reader: ConfigReader) async throws -> some ApplicationProtocol {
        let logger = {
            var logger = Logger(label: "workflow-server")
            logger.logLevel = reader.string(forKey: "log.level", as: Logger.Level.self, default: .info)
            return logger
        }()

        let router = try buildRouter(workflows: workflows)

        let app = Application(
            router: router,
            configuration: ApplicationConfiguration(reader: reader.scoped(to: "http")),
            logger: logger
        )
        return app
    }

    func buildRouter(workflows: Workflows) throws -> Router<AppRequestContext> {
        let router = Router(context: AppRequestContext.self)
        router.addMiddleware {
            LogRequestsMiddleware(.info)
        }

        router.get("/health") { _,_ in
            HTTPResponse.Status.ok
        }

        router.addRoutes(WorkflowsController(workflows: workflows).endpoints)

        return router
    }
}
