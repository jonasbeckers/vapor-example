//
//  ApiVersionMiddleware.swift
//  vapor-example
//
//  Created by Jonas Beckers on 23/12/16.
//
//

import HTTP

final class ApiVersionMiddleware: Middleware {
    
    let version: String
    
    init(version: String) {
        self.version = version
    }
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        let response = try next.respond(to: request)
        
        response.headers["Version"] = version
        
        return response
    }
    
}
