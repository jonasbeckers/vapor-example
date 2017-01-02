//
//  ApiCollection.swift
//  vapor-example
//
//  Created by Jonas Beckers on 22/12/16.
//
//

import Vapor
import HTTP
import Routing
import Auth

class ApiCollection: RouteCollection {
    
    public typealias Wrapped = HTTP.Responder
    
    public func build<Builder : RouteBuilder>(_ builder: Builder) where Builder.Value == Wrapped {
        let unauthorizedError = Abort.custom(status: .unauthorized, message: "Unauthorized")
        let protectMiddleware = ProtectMiddleware(error: unauthorizedError)
        let basicAuthMiddleware = BasicAuthenticationMiddleware()
        
        let api = builder.grouped("api").grouped(basicAuthMiddleware, protectMiddleware)
        
        let v1collection = V1Collection()
        api.collection(v1collection)
    }
    
}
