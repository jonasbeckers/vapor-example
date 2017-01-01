//
//  Droplet+Test.swift
//  vapor-example
//
//  Created by Jonas Beckers on 22/12/16.
//
//

@testable import Vapor
@testable import Library

var base = "http://localhost:8080"
var api = base + "/api/v1"

func makeTestDroplet() throws -> Droplet {
    let drop = Droplet(arguments: ["dummy/path/", "prepare"])

    try load(drop)

    try drop.runCommands()
    return drop
}

