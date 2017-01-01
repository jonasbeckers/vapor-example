//
//  OwnerController.swift
//  vapor-example
//
//  Created by Jonas Beckers on 22/12/16.
//
//

import Vapor
import HTTP

final class OwnerController {
    
    func index(_ request: Request) throws -> ResponseRepresentable {
        return try Owner.all().makeNode().converted(to: JSON.self)
    }
    
    func show(_ request: Request, _ owner: Owner) throws -> ResponseRepresentable {
        return try owner.makeNodeMore().converted(to: JSON.self)
    }
    
    func store(_ request: Request) throws -> ResponseRepresentable {
        var owner = try request.owner()
        try owner.save()
        return owner
    }
    
    func clear(_ request: Request) throws -> ResponseRepresentable {
        let owners = try Owner.all()
        try owners.forEach { owner in try Owner.removeReferences(owner: owner) }
        try Owner.deleteAll()
        return JSON([])
    }
    
    func destroy(_ request: Request, _ owner: Owner) throws -> ResponseRepresentable {
        try Owner.removeReferences(owner: owner)
        try owner.delete()
        return JSON([:])
    }
    
    func replace(_ request: Request, _ owner: Owner) throws -> ResponseRepresentable {
        guard let node = request.json?.node else {
            throw Abort.badRequest
        }
        
        var owner = owner
        try owner.update(node: node)
        try owner.save()
        return owner
    }

}

extension OwnerController: ResourceRepresentable {
    
    func makeResource() -> Resource<Owner> {
        return Resource(index: index, store: store, show: show, replace: replace, destroy: destroy, clear: clear)
    }
    
}

extension Request {
    
    func owner() throws -> Owner {
        guard let json = self.json else {
            throw Abort.badRequest
        }
        return try Owner(node: json.node)
    }
    
}
