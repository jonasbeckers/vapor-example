//
//  RootCollection.swift
//  vapor-example
//
//  Created by Jonas Beckers on 23/12/16.
//
//

import Vapor
import Routing
import HTTP
import Cookies
import Auth
import Foundation
import Turnstile

public class RootCollection: RouteCollection {
    
    private let drop: Droplet
    
    public init(drop: Droplet) {
        self.drop = drop
    }
    
    public typealias Wrapped = HTTP.Responder
    
    public func build<Builder : RouteBuilder>(_ builder: Builder) where Builder.Value == Wrapped {
        let realm = AuthenticatorRealm(User.self)
        let authMiddleware = AuthMiddleware(user: User.self, realm: realm, cache: drop.cache, makeCookie: { value in
            return Cookie(
                name: "vapor-auth",
                value: value,
                expires: Date().addingTimeInterval(60 * 60 * 5),
                secure: false,
                httpOnly: true
            )
        })
        
        let loginRedirectMiddleware = LoginRedirectMiddleware(loginRoute: "/login")
        
        let root = builder.grouped(authMiddleware)
        
        let homeCollection = HomeCollection(drop: drop)
        root.collection(homeCollection)
        
        root.get("/documentation") { req in
            return try self.drop.view.make("documentation")
        }
        
        let chatCollection = ChatCollection(drop: drop)
        root.grouped(loginRedirectMiddleware).collection(chatCollection)
        
        let spotifyCollection = SpotifyCollection(drop: drop)
        root.collection(spotifyCollection)
        
        let apiCollection = ApiCollection()
        root.collection(apiCollection)
    }
    
}
