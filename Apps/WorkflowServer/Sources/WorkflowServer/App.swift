// The Swift Programming Language
// https://docs.swift.org/swift-book
//
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import Configuration
import Hummingbird
import HummingbirdTLS
import Logging
import WorkflowEngine
import NIOSSL

public typealias AppRequestContext = BasicRequestContext

public struct App {

    public let workflows: Workflows
    public let authRegistry: AuthRegistry
    public let config: Config
    public let plugins: Plugins

    public init(
        workflows: Workflows,
        authRegistry: AuthRegistry = AuthRegistry(),
        config: Config,
        plugins: Plugins = .init()
    ) {
        self.workflows = workflows
        self.authRegistry = authRegistry
        self.config = config
        self.plugins = plugins
    }

    public func main() async throws {
        let reader = try await ConfigReader(providers: [
            EnvironmentVariablesProvider(),
            EnvironmentVariablesProvider(environmentFilePath: ".env", allowMissing: true),
            InMemoryProvider(values: [
                "http.hostname": ConfigValue(stringLiteral: config.hostname),
                "http.port": ConfigValue(integerLiteral: config.port),
                "http.serverName": "workflow-server",
            ])
        ])

        let pluginRoutes = await plugins
            .all(PluginController.self)
            .compactMap(\.endpoints)

        let app = try buildApplication(reader: reader, pluginRoutes: pluginRoutes)
        try await app.runService()
    }

    func buildApplication(
        reader: ConfigReader,
        pluginRoutes: [RouteCollection<AppRequestContext>]
    ) throws -> some ApplicationProtocol {
        let logger = {
            var logger = Logger(label: "workflow-server")
            logger.logLevel = reader.string(forKey: "log.level", as: Logger.Level.self, default: .info)
            return logger
        }()

        let router = buildRouter(
            workflows: workflows,
            authRegistry: authRegistry,
            pluginRoutes: pluginRoutes
        )

        let tls = try buildTls()

        return Application(
            router: router,
            server: try .tls(configuration: tls),
            configuration: ApplicationConfiguration(reader: reader.scoped(to: "http")),
            logger: logger
        )
    }

    func buildTls() throws -> TLSChannelConfiguration {
        let tlsConfig = try TLSConfiguration.makeServerConfiguration(
            certificateChain: NIOSSLCertificate.fromPEMFile(config.tlsCertificatePath).map { .certificate($0) },
            privateKey: .privateKey(.init(file: config.tlsPrivateKeyPath, format: .pem))
        )
        return .init(tlsConfiguration: tlsConfig)
    }

    func buildRouter(
        workflows: Workflows,
        authRegistry: AuthRegistry,
        pluginRoutes: [RouteCollection<AppRequestContext>]
    ) -> Router<AppRequestContext> {
        let router = Router(context: AppRequestContext.self)
        router.addMiddleware {
            LogRequestsMiddleware(.info)
        }

        router.get("/health") { _, _ in
            HTTPResponse.Status.ok
        }

        router.addRoutes(WorkflowInstancesController(workflows: workflows).endpoints)
        router.addRoutes(WorkflowsController(workflows: workflows).endpoints)
        router.addRoutes(AuthController(registry: authRegistry).endpoints)

        for pluginRoute in pluginRoutes {
            router.addRoutes(pluginRoute)
        }

        return router
    }
}
