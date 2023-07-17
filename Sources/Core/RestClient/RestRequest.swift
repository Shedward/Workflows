//
//  RestRequest.swift
//  Created by Vladislav Maltsev on 16.07.2023.
//

struct RestRequest<RequestBody: RestBodyEncodable, ResponseBody: RestBodyDecodable> {
    var method: RestMethod = .get
    var path: String?
    var query: RestQuery = .init()
    var headers: RestHeaders = .init()
    var body: RequestBody

    init(
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
    init(
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

extension RestRequest: KeyPathSettable { }

enum RestMethod: String {
    case get = "GET"
    case post = "POST"
}

struct RestQuery: DictionaryBuildable {
    var values: [String: String]

    init(values: [String : String]) {
        self.values = values
    }
}

struct RestHeaders: DictionaryBuildable {
    var values: [String: String]

    init(values: [String : String]) {
        self.values = values
    }
}
