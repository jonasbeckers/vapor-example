//
//  PetController.swift
//  vapor-example
//
//  Created by Jonas Beckers on 22/12/16.
//
//

import Vapor
import HTTP
import Fluent

final class PetController {
    
    func index(_ request: Request) throws -> ResponseRepresentable {
        return try Pet.all().makeNode().converted(to: JSON.self)
    }
    
    func show(_ request: Request, _ pet: Pet) throws -> ResponseRepresentable {
        return try pet.makeNodeMore().converted(to: JSON.self)
    }
    
    func store(_ request: Request) throws -> ResponseRepresentable {
        try checkForOwner(request: request)
        var pet = try request.pet()
        try pet.save()
        try pivots(for: pet, request: request)
        return pet
    }
    
    func destroy(_ request: Request, _ pet: Pet) throws -> ResponseRepresentable {
        try pet.delete()
        return JSON([])
    }
    
    private func checkForOwner(request: Request) throws {
        if let id = request.data["owner_id"]?.string {
            if try Owner.find(id) == nil {
                throw Abort.custom(status: .badRequest, message: "Owner does not exist")
            }
        }
    }
    
    private func pivots(for pet: Pet, request: Request) throws {
        if let toys = request.data["toys"]?.array {
            let found = try Toy.query().filter("id", .in, toys.flatMap { $0.string }).all()
            for item in found {
                var pivot = Pivot<Toy, Pet>(item, pet)
                try pivot.save()
            }
        }
    }
    
}

extension PetController: ResourceRepresentable {
    
    func makeResource() -> Resource<Pet> {
        return Resource(index: index, store: store, show: show, destroy: destroy)
    }
    
}

extension Request {
    
    func pet() throws -> Pet {
        guard let json = self.json else {
            throw Abort.badRequest
        }
        return try Pet(node: json.node)
    }
    
}
