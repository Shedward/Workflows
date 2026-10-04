import Core
import Hummingbird
import WorkflowEngine

/// Answers the errors this server knows with an `ErrorResponse`. Any other error is rethrown,
/// so Hummingbird keeps handling its own `HTTPError`s and answers a bare 500 for the rest.
struct ErrorResponseMiddleware: RouterMiddleware {
    typealias Context = AppRequestContext

    func handle(
        _ request: Request,
        context: Context,
        next: (Request, Context) async throws -> Response
    ) async throws -> Response {
        do {
            return try await next(request, context)
        } catch {
            guard let errorResponse = ErrorResponse(mappedFrom: error) else {
                throw error
            }
            return try errorResponse.response(from: request, context: context)
        }
    }
}

extension ErrorResponse {
    /// The one table of which error gets which HTTP status and user text.
    init?(mappedFrom error: any Error) {
        let status: HTTPResponse.Status
        let userDescription: String

        switch error {
            case is WorkflowsError.WorkflowNotFound:
                (status, userDescription) = (.notFound, "Workflow not found")
            case is WorkflowsError.WorkflowInstanceNotFound:
                (status, userDescription) = (.notFound, "Workflow instance not found")
            case is WorkflowsError.TransitionProcessNotFoundForInstance:
                (status, userDescription) = (.internalServerError, "Transition process not found for instance")
            case is WorkflowsError.InvalidRouteTarget:
                (status, userDescription) = (.internalServerError, "Transition routed to an undeclared target state")
            case is WorkflowsError.InstanceNotAsking:
                (status, userDescription) = (.conflict, "Workflow instance is not waiting for an answer")
            case let failure as Failure:
                (status, userDescription) = (.internalServerError, failure.userDescription)
            default:
                return nil
        }

        self.init(status: status, userDescription: userDescription, debugDescription: String(describing: error))
    }
}
