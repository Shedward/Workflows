import Foundation
@testable import Rest
import Synchronization
import Testing

/// Answers every request of a session with the canned status and body.
final class CannedResponse: URLProtocol {
    static let canned = Mutex<(status: Int, body: Data)>((200, Data()))

    override static func canInit(with request: URLRequest) -> Bool {
        true
    }

    override static func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        let (status, body) = Self.canned.withLock { $0 }
        let response = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: body)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {
    }
}

@Suite("Network client: fetch", .serialized)
struct NetworkRestClientFetchTests {
    private func client() -> NetworkRestClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [CannedResponse.self]
        return NetworkRestClient(endpoint: .init(host: URL(string: "https://example.test")!), session: URLSession(configuration: configuration))
    }

    @Test func aRefusedStatusCarriesTheStatusAndTheBody() async throws {
        CannedResponse.canned.withLock { $0 = (409, Data(#"{"userDescription":"not now"}"#.utf8)) }

        let rejected = await #expect(throws: ResponseRejected.self) {
            try await client().fetch(Request<EmptyBody, EmptyBody>(.get, "/items"))
        }

        #expect(rejected?.statusCode == 409)
        #expect(rejected.flatMap { String(bytes: $0.body, encoding: .utf8) } == #"{"userDescription":"not now"}"#)
    }

    @Test func anAcceptedStatusReturnsTheBody() async throws {
        CannedResponse.canned.withLock { $0 = (200, Data("payload".utf8)) }

        let body = try await client().fetch(Request<EmptyBody, PlainTextBody>(.get, "/items"))

        #expect(body.body == "payload")
    }
}
