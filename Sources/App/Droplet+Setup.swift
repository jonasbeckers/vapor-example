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
import SwiftyBeaver
import SwiftyBeaverVapor

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
    let console = ConsoleDestination()
    let file = FileDestination()
    file.logFileURL = URL(fileURLWithPath: "/tmp/VaporLogs.log")
    let cloud = SBPlatformDestination(appID: "9Gz0m2", appSecret: "NFEaoh4ihO9pbscvuqw9nydn6xfvK4pt", encryptionKey: "gdssBjmmdgiyzunvzeywfasdxeuha3qz")
    drop.addProvider(SwiftyBeaverProvider(destinations: [console, file, cloud]))
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
