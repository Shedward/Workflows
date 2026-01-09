import Foundation
import Core

// TODO: Resolve collision with module name
public protocol RestClient {
    func fetch<RequestBody, ResponseBody>(
        _ request: Request<RequestBody, ResponseBody>
    ) async throws -> ResponseBody
}
