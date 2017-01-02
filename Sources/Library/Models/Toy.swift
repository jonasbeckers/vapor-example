//
//  Toys.swift
//  vapor-example
//
//  Created by Jonas Beckers on 21/12/16.
//
//

import Vapor
import Fluent

public final class Toy: Model {
    
     public var exists: Bool = false
    
     public var id: Node?
     public var name: String
    
    public init(name: String) {
        self.name = name
    }
    
    required public init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
    }
    
    public func makeNode(context: Context) throws -> Node {
        return try Node(node: ["id": id, "name": name])
    }
    
    func makeNodeMore(context: Context = EmptyNode) throws -> Node {
        let node = try pets().all().makeNode()
        return try Node(node: ["id": id, "name": name, "pets": node])
    }
    
    func pets() throws -> Siblings<Pet> {
        return try siblings()
    }
    
    public func willDelete() {
        do {
            try Pivot<Toy, Pet>.query().filter("toy_id", .equals, id!).delete()
        } catch { }
    }
    
}

extension Toy {
    
     public static func prepare(_ database: Database) throws {
        try database.create("toys") { table in
            table.id()
            table.string("name")
        }
    }
    
    public static func revert(_ database: Database) throws {
        try database.delete("toys")
    }
    
}
