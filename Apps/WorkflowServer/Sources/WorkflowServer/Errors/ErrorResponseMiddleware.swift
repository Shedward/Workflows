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
    /// The one table of which error gets which HTTP status. The user text is the error's own
    /// `userDescription`, the same text that `transitionState.failed` stores.
    init?(mappedFrom error: any Error) {
        let status: HTTPResponse.Status

        switch error {
            case is InvalidRequestBody, is WorkflowsError.MissingRequiredInputs:
                status = .badRequest
            case is WorkflowsError.WorkflowNotFound, is WorkflowsError.WorkflowInstanceNotFound:
                status = .notFound
            case is WorkflowsError.TransitionProcessNotFoundForInstance, is WorkflowsError.InstanceNotAsking:
                status = .conflict
            case is WorkflowsError.InvalidRouteTarget, is Failure:
                status = .internalServerError
            default:
                return nil
        }

        self.init(
            status: status,
            userDescription: (error as? DescriptiveError)?.userDescription ?? String(describing: error),
            debugDescription: String(describing: error)
        )
    }
}
