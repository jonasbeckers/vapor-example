//
//  Droplet+Setup.swift
//  vapor-example
//
//  Created by Jonas Beckers on 21/12/16.
//
//

import Vapor
import VaporMySQL
import Fluent
import Foundation
import VaporRedis
import Library

public func load(_ drop: Droplet) throws {
    addPreparations(drop)
    addCommands(drop)
    addCustomLeafTags(drop)
    
    try addProviders(drop)
    
    let rootCollection = RootCollection(drop: drop)
    drop.collection(rootCollection)
}

public func addPreparations(_ drop: Droplet) {
    let preparations: [Preparation.Type] = [Owner.self, Pet.self, Toy.self, Pivot<Toy, Pet>.self, User.self]
    drop.preparations.append(contentsOf: preparations)
}

public func addProviders(_ drop: Droplet) throws {
    try drop.addProvider(VaporMySQL.Provider.self)
    try drop.addProvider(VaporRedis.Provider(config: drop.config))
}

public func addCommands(_ drop: Droplet) {
    let testCommmand = TestCommmand(console: drop.console)
    drop.commands.append(testCommmand)
}

public func addCustomLeafTags(_ drop: Droplet) {
    if let leaf = drop.view as? LeafRenderer {
        leaf.stem.register(Empty())
    }
}
