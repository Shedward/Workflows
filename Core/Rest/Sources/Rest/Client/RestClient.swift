import Foundation
import Core

public protocol RestClient: Sendable {
    func fetch<RequestBody, ResponseBody>(
        _ request: Request<RequestBody, ResponseBody>
    ) async throws -> ResponseBody
}
