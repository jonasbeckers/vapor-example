//
//  ItunesController.swift
//  vapor-example
//
//  Created by Jonas Beckers on 25/12/16.
//
//

import Vapor
import HTTP

final class SpotifyController {
    
    let drop: Droplet
    
    init(drop: Droplet) {
        self.drop = drop
    }
    
    func index(_ request: Request) throws -> ResponseRepresentable {
        let user = try? request.user()
        return try drop.view.make("spotify", ["authenticated": user != nil])
    }
    
    func search(_ request: Request) throws -> ResponseRepresentable {
        if let searchTerm = request.query?["searchTerm"]?.string, searchTerm != "" {
            
            let result = try drop.client.get("https://api.spotify.com/v1/search?type=artist&q=\(searchTerm)")
            
            if let items = result.json?["artists", "items"]?.array {
                var artists = Array<Artist>()
                
                for item in items {
                    if let object = item.object, let name = object["name"]?.string, let id = object["id"]?.string {
                        let artist = Artist(id: id, name: name)
                        artists.append(artist)
                    }
                }
                
                return artists.makeResponse(for: request)
            }
            
            throw SpotifyError.apiError(page: "artists")
        }
        throw SpotifyError.emptySearchTerm
    }
    
    func detail(_ request: Request) throws -> ResponseRepresentable {
        if let id = request.parameters["id"]?.string {
            
            let result = try drop.client.get("https://api.spotify.com/v1/artists/\(id)")
            
            if let object = result.json?.node, let name = object["name"]?.string, let id = object["id"]?.string, let popularity = object["popularity"]?.int, let followers = object["followers", "total"]?.int, let genres = object["genres"]?.array {
                
                let artist = Artist(id: id, name: name, popularity: popularity, followers: followers)
                artist.imageUrl = object["images"]?.pathIndexableArray?[2].object?["url"]?.string
                artist.spotifyLink = object["href"]?.string
                artist.genres = genres.flatMap { $0.string }
                
                return artist.makeResponse(for: request)
            }
        }
        throw SpotifyError.artistNotFound
    }
    
}

enum SpotifyError: Error {
    
    case apiError(page: String)
    case emptySearchTerm
    case artistNotFound
    
    var message: String {
        switch self {
        case .apiError:
            return "unknown error"
        case .emptySearchTerm:
            return "the searchterm cannot be empty"
        case .artistNotFound:
            return "the artist does not exist"
        }
    }
    
    func jsonError() throws -> JSON {
        return try JSON(Node(node: ["error": true, "message": message]))
    }
    
}
