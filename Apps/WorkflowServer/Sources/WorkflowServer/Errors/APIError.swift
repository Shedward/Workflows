import Hummingbird

/// An error the server answers with an `ErrorResponse` body: its own HTTP status,
/// a text for the user, and `String(describing:)` of the error as the debug text.
public protocol APIError: HTTPResponseError {
    var userDescription: String { get }
}

public extension APIError {
    func response(from request: Request, context: some RequestContext) throws -> Response {
        try ErrorResponse(
            status: status,
            userDescription: userDescription,
            debugDescription: String(describing: self)
        )
        .response(from: request, context: context)
    }
}
