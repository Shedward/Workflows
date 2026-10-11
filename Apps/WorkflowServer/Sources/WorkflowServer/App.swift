import Hummingbird
import HummingbirdTLS
import Logging
import NIOSSL
import WorkflowEngine

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
        let pluginRoutes = await plugins
            .all(PluginController.self)
            .map(\.endpoints)

        let app = try buildApplication(pluginRoutes: pluginRoutes)
        try await workflows.run()
        try await app.runService()
    }

    func buildApplication(pluginRoutes: [RouteCollection<AppRequestContext>]) throws -> some ApplicationProtocol {
        var logger = Logger(label: "workflow-server")
        logger.logLevel = config.logLevel

        return Application(
            router: buildRouter(pluginRoutes: pluginRoutes),
            server: try .tls(configuration: buildTls()),
            configuration: ApplicationConfiguration(
                address: .hostname(config.hostname, port: config.port),
                serverName: "workflow-server"
            ),
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

    func buildRouter(pluginRoutes: [RouteCollection<AppRequestContext>]) -> Router<AppRequestContext> {
        let router = Router(context: AppRequestContext.self)
        router.addMiddleware {
            LogRequestsMiddleware(.info)
            ErrorResponseMiddleware()
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
