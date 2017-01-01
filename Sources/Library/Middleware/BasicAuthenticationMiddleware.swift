//
//  BasicAuthenticationMiddleware.swift
//  vapor-example
//
//  Created by Jonas Beckers on 23/12/16.
//
//

import HTTP
import Vapor
import Turnstile

final class BasicAuthenticationMiddleware: Middleware {
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        if let apiKey = request.auth.header?.basic {
            try? request.auth.login(apiKey, persist: false)
        }
        
        return try next.respond(to: request)
    }
    
}
