//
//  SpotifyMiddleware.swift
//  vapor-example
//
//  Created by Jonas Beckers on 26/12/16.
//
//

import Vapor
import HTTP
import JSON

final class SpotifyMiddleware: Middleware {
    
    let drop: Droplet
    
    init(drop: Droplet) {
        self.drop = drop
    }
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        do {
            let response = try next.respond(to: request)
            
            if let artists = response.artists {
                let node = try artists.makeNode()
                
                if request.accept.prefers("html") {
                    let user = try? request.user()
                    let view = try drop.view.make("artists", ["artists": node, "authenticated": user != nil])
                    return view.makeResponse()
                } else {
                    response.json = try node.converted(to: JSON.self)
                }
            }
            
            if let artist = response.artist {
                let node = try artist.makeNodeMore()
                
                if request.accept.prefers("html") {
                    let user = try? request.user()
                    let view = try drop.view.make("detail", ["artist": node, "authenticated": user != nil], for: request)
                    return view.makeResponse()
                } else {
                    response.json = try node.converted(to: JSON.self)
                }
            }
            
            return response
            
        } catch SpotifyError.emptySearchTerm {
            let error = SpotifyError.emptySearchTerm
            if request.accept.prefers("html") {
                let user = try? request.user()
                return try drop.view.make("spotify", ["authenticated": user != nil, "message": error.message]).makeResponse()
            } else {
                return try error.jsonError().makeResponse()
            }
        } catch SpotifyError.apiError(let page) {
            let error = SpotifyError.apiError(page: page)
            if request.accept.prefers("html") {
                let user = try? request.user()
                return try drop.view.make(page, ["authenticated": user != nil, "message": error.message]).makeResponse()
            } else {
                return try error.jsonError().makeResponse()
            }
        } catch SpotifyError.artistNotFound {
            let error = SpotifyError.artistNotFound
            if request.accept.prefers("html") {
                let user = try? request.user()
                return try drop.view.make("detail", ["authenticated": user != nil, "message": error.message]).makeResponse()
            } else {
                return try error.jsonError().makeResponse()
            }
        }
    } 
    
}

