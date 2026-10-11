import Core
import Hummingbird
import WorkflowEngine

/// Answers every `DescriptiveError` with an `ErrorResponse`. Any other error is rethrown,
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
    /// `ErrorKind` decides the status. The user text is the error's own `userDescription`, the same
    /// text that `transitionState.failed` stores.
    init?(mappedFrom error: any Error) {
        guard let descriptive = error as? DescriptiveError else {
            return nil
        }

        let status: HTTPResponse.Status = switch descriptive.kind {
            case .invalidRequest:
                .badRequest
            case .notFound:
                .notFound
            case .conflict:
                .conflict
            case .internal:
                .internalServerError
        }

        self.init(
            status: status,
            userDescription: descriptive.userDescription,
            debugDescription: String(describing: error)
        )
    }
}
