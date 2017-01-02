//
//  ApiCollection.swift
//  vapor-example
//
//  Created by Jonas Beckers on 22/12/16.
//
//

import Vapor
import Routing
import HTTP
import Turnstile
import TurnstileWeb
import Auth

class V1Collection: RouteCollection {
    
    typealias Wrapped = HTTP.Responder
    
    func build<Builder : RouteBuilder>(_ builder: Builder) where Builder.Value == Wrapped {
        let versionMiddleware = ApiVersionMiddleware(version: "API v1.0")
        let v1 = builder.grouped("v1").grouped(versionMiddleware)
        
        let ownerController = OwnerController()
        v1.resource("owners", ownerController)
        
        let petController = PetController()
        v1.resource("pets", petController)
        
        let toyController = ToyController()
        v1.resource("toys", toyController)
    }
    
}
