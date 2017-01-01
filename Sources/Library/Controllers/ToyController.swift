//
//  ToyController.swift
//  vapor-example
//
//  Created by Jonas Beckers on 23/12/16.
//
//

import Vapor
import HTTP

final class ToyController {
    
    func index(_ request: Request) throws -> ResponseRepresentable {
        return try Toy.all().makeNode().converted(to: JSON.self)
    }
    
    func show(_ request: Request, _ toy: Toy) throws -> ResponseRepresentable {
        return try toy.makeNodeMore().converted(to: JSON.self)
    }
    
    func store(_ request: Request) throws -> ResponseRepresentable {
        var toy = try request.toy()
        try toy.save()
        return toy
    }
    
    func destroy(_ request: Request, _ toy: Toy) throws -> ResponseRepresentable {
        try toy.delete()
        return JSON([])
    }
    
}

extension ToyController: ResourceRepresentable {
    
    func makeResource() -> Resource<Toy> {
        return Resource(index: index, store: store, show: show, destroy: destroy)
    }
    
}

extension Request {
    
    func toy() throws -> Toy {
        guard let json = self.json else {
            throw Abort.badRequest
        }
        return try Toy(node: json.node)
    }
    
}
