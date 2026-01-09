//
//  ApiResponse.swift
//  WorkflowServer
//
//  Created by Vlad Maltsev on 08.01.2026.
//

import Rest
import Hummingbird

struct ApiResponse<ResponseBody: DataEncodable>: ResponseGenerator {
    let responseBody: ResponseBody

    func response(from request: Request, context: some RequestContext) throws -> Response {
        let body = try responseBody.data().map { Hummingbird.ResponseBody(byteBuffer: ByteBuffer(data: $0)) } ?? .init()
        return Response(status: .ok, body: body)
    }
}
