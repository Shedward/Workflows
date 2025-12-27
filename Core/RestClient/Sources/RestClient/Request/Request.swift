//
//  Request.swift
//  RestClient
//
//  Created by Vlad Maltsev on 21.12.2025.
//

import Core

public struct Request<
    RequestBody: DataEncodable,
    ResponseBody: DataDecodable
> {
    public var method: Method
    public var path: String?
    public var query: Query
    public var headers: Headers
    public var body: RequestBody
    public var metadata: Metadata

    public init(
        method: Method = .get,
        path: String? = nil,
        query: Query = .init(),
        headers: Headers = .init(),
        body: RequestBody,
        metadata: Metadata = .init()
    ) {
        self.method = method
        self.path = path
        self.query = query
        self.headers = headers
        self.body = body
        self.metadata = metadata
    }

    public init(_ method: Method = .get, _ path: String? = nil, body: RequestBody) {
        self.init(method: method, path: path, body: body)
    }
}

extension Request: Sendable where RequestBody: Sendable {}

extension Request: Defaultable where RequestBody: Defaultable {
    public init() {
        self.init(body: .init())
    }

    public init(_ method: Method = .get, _ path: String? = nil) {
        self.init(method: method, path: path, body: .init())
    }
}

extension Request: Modifiers {
    public func method(_ method: Method) -> Self {
        with { $0.method = method  }
    }

    public func path(_ path: String?) -> Self {
        with { $0.path = path }
    }

    public func query(_ query: Query) -> Self {
        with { $0.query = query }
    }

    public func query(_ key: String, to value: QueryConvertible?) -> Self {
        with { $0.query[key] = value }
    }

    public func headers(_ headers: Headers) -> Self {
        with { $0.headers = headers }
    }

    public func header(_ key: String, to value: String?) -> Self {
        with { $0.headers[key] = value }
    }

    public func body(_ body: RequestBody) -> Self {
        with { $0.body = body }
    }

    public func decorate<Decorator: RequestDecorator>(
        _ decorator: Decorator
    ) async throws -> Self {
        try await decorator.decorate(self)
    }

    public func metadata<Key: MetadataKey>(_ key: Key.Type, to value: Key.Value) -> Self {
        with { $0.metadata[Key.self] = value }
    }
}
