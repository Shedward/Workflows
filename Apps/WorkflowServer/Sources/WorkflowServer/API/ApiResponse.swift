//
//  ApiResponse.swift
//  WorkflowServer
//
//  Created by Vlad Maltsev on 08.01.2026.
//

import Hummingbird
import Rest

struct ApiResponse<ResponseBody: DataEncodable>: ResponseGenerator {
    let responseBody: ResponseBody

    func response(from request: Request, context: some RequestContext) throws -> Response {
        let body = try responseBody.data().map { Hummingbird.ResponseBody(byteBuffer: ByteBuffer(data: $0)) } ?? .init()
        var headers = HTTPFields()
        if let contentType = responseBody.contentType {
            headers[.contentType] = contentType
        }
        return Response(status: .ok, headers: headers, body: body)
    }
}
