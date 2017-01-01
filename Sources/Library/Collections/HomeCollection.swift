//
//  HomeCollection.swift
//  vapor-example
//
//  Created by Jonas Beckers on 28/12/16.
//
//

import Vapor
import Routing
import HTTP
import Turnstile
import TurnstileWeb
import Auth

class HomeCollection: RouteCollection {

    let drop: Droplet
    
    init(drop: Droplet) {
        self.drop = drop
    }
    
    typealias Wrapped = HTTP.Responder
    
    func build<Builder : RouteBuilder>(_ builder: Builder) where Builder.Value == Wrapped {
        let homeController = Hometroller(drop: drop)
        
        let loginGroup = builder.grouped("login")
        loginGroup.get(handler: homeController.loginPage)
        loginGroup.post(handler: homeController.login)
        
        loginGroup.group("google") { googleGroup in
            
            googleGroup.get(handler: homeController.googleLogin)
            googleGroup.get("consumer", handler: homeController.googleLoginConsumer)
            
        }
        
        loginGroup.group("facebook") { facebookGroup in
            
            facebookGroup.get(handler: homeController.facebookLogin)
            facebookGroup.get("consumer", handler: homeController.facebookLoginConsumer)
            
        }
        
        let registerGroup = builder.grouped("register")
        registerGroup.get(handler: homeController.registerPage)
        registerGroup.post(handler: homeController.register)

        builder.get(handler: homeController.dashBoard)
        builder.post("logout", handler: homeController.logout)
    }
    
}
