//
//  SpotifyCollection.swift
//  vapor-example
//
//  Created by Jonas Beckers on 26/12/16.
//
//

import Routing
import HTTP
import Vapor

class SpotifyCollection: RouteCollection {
    
    let drop: Droplet
    
    init(drop: Droplet) {
        self.drop = drop
    }
    
    typealias Wrapped = HTTP.Responder
    
    func build<Builder : RouteBuilder>(_ builder: Builder) where Builder.Value == Wrapped {
        let spotifyMiddleware = SpotifyMiddleware(drop: drop)
        let spotifyController = SpotifyController(drop: drop)
        
        let spotifyGroup = builder.grouped("spotify").grouped(spotifyMiddleware)
        spotifyGroup.get(handler: spotifyController.index)
        spotifyGroup.get("search", handler: spotifyController.search)
        spotifyGroup.get("detail", ":id", handler: spotifyController.detail)
    }
    
}
