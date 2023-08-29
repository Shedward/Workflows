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

public struct RestQuery {
    public var values: [String: String]

    public init(values: [String: String]) {
        self.values = values
    }
}

extension RestQuery: DictionaryBuildable {
    public static func set(_ key: String, to value: Int?) -> Self {
        guard let value else {
            return Self()
        }
        return Self(values: [key: String(value)])
    }
    
    public func set(_ key: Key, to value: Int?) -> Self {
        var values = values
        values[key] = value.map(String.init)
        return Self(values: values)
    }
}

public struct RestHeaders: DictionaryBuildable {
    public var values: [String: String]

    public init(values: [String: String]) {
        self.values = values
    }
}
