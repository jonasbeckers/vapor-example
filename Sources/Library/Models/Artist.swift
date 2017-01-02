//
//  Artist.swift
//  vapor-example
//
//  Created by Jonas Beckers on 26/12/16.
//
//

import Vapor
import HTTP

class Artist {
    
    var id: String
    var name: String
    var popularity: Int
    var followers: Int
    var spotifyLink: String? = nil
    var imageUrl: String? = nil
    var genres: [String] = []
    
    init(id: String, name: String, popularity: Int = 0, followers: Int = 0) {
        self.id = id
        self.name = name
        self.popularity = popularity
        self.followers = followers
    }
    
    func makeNode() throws -> Node {
        return try Node(node: ["id": id, "name": name])
    }
    
    func makeNodeMore() throws -> Node {
        return try Node(node: ["id": id, "name": name, "followers": followers, "popularity": popularity, "spotifyLink": spotifyLink, "imageUrl": imageUrl, "genres": try genres.makeNode()])
    }
    
    func makeResponse(for request: Request) -> Response {
        let response = Response()
        response.artist = self
        return response
    }
    
}

extension Sequence where Iterator.Element == Artist {
    
    func makeResponse(for request: Request) -> Response {
        let response = Response()
        response.artists = Array(self)
        return response
    }
    
    func makeNode() throws -> Node {
        let nodes = try array.map { try $0.makeNode() }
        return try nodes.makeNode()
    }
    
}

extension Response {
    
    var artists: [Artist]? {
        get {
            return storage["artists"] as? [Artist]
        }
        set {
            storage["artists"] = newValue
        }
    }
    
    var artist: Artist? {
        get {
            return storage["artist"] as? Artist
        }
        set {
            storage["artist"] = newValue
        }
    }
    
}
