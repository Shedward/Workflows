//
//  RestRequest.swift
//  Created by Vladislav Maltsev on 16.07.2023.
//

import Prelude

public struct RestRequest<
    RequestBody: RestBodyEncodable,
    ResponseBody: RestBodyDecodable
>: KeyPathSettable {
    public var method: RestMethod = .get
    public var path: String?
    public var query: RestQuery = .init()
    public var headers: RestHeaders = .init()
    public var body: RequestBody

    public init(
        method: RestMethod = .get,
        path: String? = nil,
        query: RestQuery = .init(),
        headers: RestHeaders = .init(),
        body: RequestBody
    ) {
        self.method = method
        self.path = path
        self.query = query
        self.headers = headers
        self.body = body
    }
}

extension RestRequest where RequestBody: DefaultInitable {
    public init(
        method: RestMethod = .get,
        path: String? = nil,
        query: RestQuery = .init(),
        headers: RestHeaders = .init()
    ) {
        self.init(
            method: method,
            path: path,
            query: query,
            headers: headers,
            body: .init()
        )
    }
}

public enum RestMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
}

public struct RestQuery: Equatable, DictionaryBuildable {
    public var values: [String: String]

    public init(values: [String: String]) {
        self.values = values
    }
}

extension RestQuery {

    public func set(_ key: Key, to value: Int?) -> Self {
        var values = values
        values[key] = value.map(String.init)
        return Self(values: values)
    }

    public func set(_ key: String, toCommaSeparated values: [String]) -> Self {
        guard !values.isEmpty else {
            return self
        }

        return self.set(key, to: values.joined(separator: ","))
    }
}

extension Filter where T == RestQuery {
    public static func contains(_ query: RestQuery) -> Filter {
        .custom { $0.contains(query) }
    }

    public static func exact(_ query: RestQuery, forKeys keys: Set<RestQuery.Key>) -> Filter {
        .custom { $0.withKeys(keys) == query }
    }
}

public struct RestHeaders: Equatable, DictionaryBuildable {
    public var values: [String: String]

    public init(values: [String: String]) {
        self.values = values
    }
}

extension Filter where T == RestHeaders {
    public static func contains(_ query: RestHeaders) -> Filter {
        .custom { $0.contains(query) }
    }
}
