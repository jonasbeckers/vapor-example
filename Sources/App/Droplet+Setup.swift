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
    drop.addProvider(SwiftyBeaverProvider(destinations: destinations(drop: drop)))
}

public func destinations(drop: Droplet) -> [BaseDestination] {
    var destinations = [BaseDestination]()
    
    let console = ConsoleDestination()
    destinations += console
    let file = FileDestination()
    destinations += file
    file.logFileURL = URL(fileURLWithPath: "/tmp/VaporLogs.log")
    
    if let cloud = cloudLocation(drop: drop) {
        destinations += cloud
    }
    return destinations
}

public func cloudLocation(drop: Droplet) -> SBPlatformDestination? {
    guard let appID = drop.config["swiftybeaver", "appID"]?.string, let appSecret = drop.config["swiftybeaver", "appSecret"]?.string, let encryptionKey = drop.config["swiftybeaver", "encryptionKey"]?.string else {
        return nil
    }
    
    let cloud = SBPlatformDestination(appID: appID, appSecret: appSecret, encryptionKey: encryptionKey)
    return cloud
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
