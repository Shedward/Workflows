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
}

public struct RestQuery: DictionaryBuildable {
    public var values: [String: String]

    public init(values: [String: String]) {
        self.values = values
    }
}

public struct RestHeaders: DictionaryBuildable {
    public var values: [String: String]

    public init(values: [String: String]) {
        self.values = values
    }
}
