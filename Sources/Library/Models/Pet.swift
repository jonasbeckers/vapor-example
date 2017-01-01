//
//  Pet.swift
//  vapor-example
//
//  Created by Jonas Beckers on 21/12/16.
//
//

import Vapor
import Fluent

public final class Pet: Model {
    
     public var exists: Bool = false
    
     public var id: Node?
     public var ownerId: Node?
    
     public var name: String
     public var type: String
    
    public init(name: String, type: String) {
        self.name = name
        self.type = type
    }
    
    required public init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        ownerId = try node.extract("owner_id")
        name = try node.extract("name")
        type = try node.extract("type")
    }
    
    public func makeNode(context: Context) throws -> Node {
        return try Node(node: ["id": id, "owner_id": ownerId, "name": name, "type": type])
    }
    
    func makeNodeMore(context: Context = EmptyNode) throws -> Node {
        let nodes = try toys().all().map { try $0.makeNode() }
        return try Node(node: ["id": id, "owner_id": ownerId, "name": name, "type": type, "toys": try nodes.makeNode()])
    }
    
    func makeNodeLess(context: Context = EmptyNode) throws -> Node {
        return try Node(node: ["id": id, "name": name, "type": type])
    }
    
    func owner() throws -> Parent<Owner> {
        return try parent(ownerId)
    }
    
    func toys() throws -> Siblings<Toy> {
        return try siblings()
    }
    
    public func willDelete() {
        do {
            try Pivot<Toy, Pet>.query().filter("pet_id", .equals, id!)
        } catch { }
    }
    
}

extension Pet {
    
     public static func prepare(_ database: Database) throws {
        try database.create("pets") { table in
            table.id()
            table.parent(Owner.self, optional: true, unique: false, default: nil)
            table.string("name")
            table.string("type")
        }
    }
    
     public static func revert(_ database: Database) throws {
        try database.delete("pets")
    }
    
}
