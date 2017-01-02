//
//  Owner.swift
//  vapor-example
//
//  Created by Jonas Beckers on 21/12/16.
//
//

import Vapor
import Fluent
import  HTTP

public final class Owner: Model {
    
    public var exists: Bool = false
    
    public var id: Node?
    public var name: Valid<Name>
    
    public init(name: String) throws {
        self.id = nil
        self.name = try name.validated()
    }
    
    required public init(node: Node, in context: Context) throws {
        self.id = try node.extract("id")
        let name: String = try node.extract("name")
        self.name = try name.validated()
    }
    
    func update(node: Node) throws {
        let name: String = try node.extract("name")
        self.name = try name.validated()
    }
    
    public func makeNode(context: Context) throws -> Node {
        return try Node(node: ["id": id, "name": name.value])
    }
    
    func makeNodeMore(context: Context = EmptyNode) throws -> Node {
        let nodes = try pets().all().map { try $0.makeNodeLess(context: Node.null) }
        return try Node(node: ["id": id, "name": name.value, "pets": try nodes.makeNode()])
    }
    
    func pets() throws -> Children<Pet> {
        return children()
    }
    
    public func willDelete() {
        do {
            try Owner.removeReferences(owner: self)
        } catch { }
    }
    
    static func removeReferences(owner: Owner) throws {
        let node = try Node(node: ["owner_id": nil])
        try owner.pets().makeQuery().modify(node)
    }
    
}

extension Owner {
    
    public static func prepare(_ database: Database) throws {
        try database.create("owners") { table in
            table.id()
            table.string("name")
        }
    }
    
    public static func revert(_ database: Database) throws {
        try database.delete("owners")
    }
    
}
