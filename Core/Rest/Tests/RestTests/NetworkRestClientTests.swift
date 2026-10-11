import Foundation
@testable import Rest
import Testing

@Suite("Network client: request composition")
struct NetworkRestClientTests {
    let endpoint = NetworkRestClient.Endpoint(host: URL(string: "https://example.test")!)

    @Test func queryValuesArePercentEncodedOnce() throws {
        let request = Request<EmptyBody, EmptyBody>(.get, "/search").query("q", to: "a b&c")

        let urlRequest = try NetworkRestClient.urlRequest(for: request, at: endpoint)

        #expect(urlRequest.url?.absoluteString == "https://example.test/search?q=a%20b%26c")
    }

    @Test func pathMethodHeadersAndBodyComeFromTheGivenRequest() throws {
        let request = Request<PlainTextBody, EmptyBody>(.post, "/items", body: PlainTextBody("payload"))
            .header("X-Token", to: "secret")
            .query("page", to: 2)
            .query("all", to: true)

        let urlRequest = try NetworkRestClient.urlRequest(for: request, at: endpoint)

        #expect(urlRequest.url?.absoluteString == "https://example.test/items?all=true&page=2")
        #expect(urlRequest.httpMethod == "POST")
        #expect(urlRequest.value(forHTTPHeaderField: "X-Token") == "secret")
        #expect(urlRequest.value(forHTTPHeaderField: "Content-Type") == "text/plain; charset=utf-8")
        #expect(urlRequest.httpBody.flatMap { String(bytes: $0, encoding: .utf8) } == "payload")
    }

    @Test func aNilQueryValueIsLeftOut() throws {
        let request = Request<EmptyBody, EmptyBody>(.get, "/items").query("filter", to: String?.none)

        let urlRequest = try NetworkRestClient.urlRequest(for: request, at: endpoint)

        #expect(urlRequest.url?.absoluteString == "https://example.test/items")
    }
}
