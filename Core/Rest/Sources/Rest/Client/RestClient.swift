import Foundation
import Core

public protocol RestClient {
    func fetch<RequestBody, ResponseBody>(
        _ request: Request<RequestBody, ResponseBody>
    ) async throws -> ResponseBody
}
