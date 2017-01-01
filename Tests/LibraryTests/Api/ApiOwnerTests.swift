//
//  OwnerTests.swift
//  vapor-example
//
//  Created by Jonas Beckers on 27/12/16.
//
//

import XCTest
import Vapor
import HTTP
import Turnstile
@testable import Library

class ApiOwnerTests: XCTestCase {
    
   static var allTests : [(String, (ApiOwnerTests) -> () throws -> Void)] {
        return [
            ("testGetOwners", testGetOwners),
            ("testGetOwnerWithId", testGetOwnerWithId),
            ("testPostOwner", testPostOwner),
            ("testPutOwner", testPutOwner),
            ("testDeleteOwnerWithId", testDeleteOwnerWithId),
            ("testDeleteOwners", testDeleteOwners),
        ]
    }
    
    override func setUp() {
        super.setUp()
        do {
             _ = try makeTestDroplet()
            let node = try Node(node: ["username": "mike", "password": "", "facebook_id": "", "google_id": "", "api_key_id": "123", "api_key_secret": "abc"])
            var user = try User(node: node, in: EmptyNode)
            try user.save()
        } catch { }
    }
    
    override func tearDown() {
        do {
            _ = try makeTestDroplet()
            try User.deleteAll()
        } catch { }
        super.tearDown()
    }
    
    func testGetOwners() throws {
        let drop = try makeTestDroplet()
        
        var owner = try Owner(name: "John")
        try owner.save()
         
        let request = try Request(method: .get, uri: "\(api)/owners")
        request.headers["Authorization"] = "Basic " + "123:abc".toBase64()
        
        let response = try drop.respond(to: request)
        let node = response.json?.node
        let name = node?.array?.first?.object?["name"]?.string
        
        XCTAssertEqual(response.status.statusCode, 200)
        XCTAssertEqual(response.contentType, "application/json; charset=utf-8")
        XCTAssertEqual(name, "John")
        
        try Owner.deleteAll()
    }
    
    func testGetOwnerWithId() throws {
        let drop = try makeTestDroplet()
        
        var owner = try Owner(name: "John")
        try owner.save()
        
        let request = try Request(method: .get, uri: "\(api)/owners/" + owner.id!.string!)
        request.headers["Authorization"] = "Basic " + "123:abc".toBase64()
        
        let response = try drop.respond(to: request)
        let node = response.json?.node
        let id = node?.object?["id"]?.int
        let name = node?.object?["name"]?.string
        
        XCTAssertEqual(response.status.statusCode, 200)
        XCTAssertEqual(response.contentType, "application/json; charset=utf-8")
        XCTAssertEqual(id, owner.id?.int)
        XCTAssertEqual(name, "John")
        
        try Owner.deleteAll()
    }
    
    func testPostOwner() throws {
        let drop = try makeTestDroplet()
        
        let json = try JSON(node: ["name": "John"])
        
        let request = try Request(method: .post, uri: "\(api)/owners/")
        request.headers["Authorization"] = "Basic " + "123:abc".toBase64()
        request.json = json
        
        let response = try drop.respond(to: request)
        let node = response.json?.node
        let id = node?.object?["id"]?.int
        let name = node?.object?["name"]?.string
        
        XCTAssertEqual(response.status.statusCode, 200)
        XCTAssertEqual(response.contentType, "application/json; charset=utf-8")
        XCTAssertNotNil(id)
        XCTAssertEqual(name, "John")
        
        try Owner.deleteAll()
    }
    
    func testPutOwner() throws {
        let drop = try makeTestDroplet()
        
        var owner = try Owner(name: "John")
        try owner.save()
        
        let json = try JSON(node: ["id": owner.id!.int!, "name": "Mike"])
        
        let request = try Request(method: .put, uri: "\(api)/owners/" + owner.id!.string!)
        request.headers["Authorization"] = "Basic " + "123:abc".toBase64()
        request.json = json
        
        let response = try drop.respond(to: request)
        let node = response.json?.node
        let id = node?.object?["id"]?.int
        let name = node?.object?["name"]?.string
        
        XCTAssertEqual(response.status.statusCode, 200)
        XCTAssertEqual(response.contentType, "application/json; charset=utf-8")
        XCTAssertNotNil(id)
        XCTAssertEqual(name, "Mike")
        
        try Owner.deleteAll()
    }
    
    func testDeleteOwnerWithId() throws {
        let drop = try makeTestDroplet()
        var owner = try Owner(name: "John")
        try owner.save()
        
        let request = try Request(method: .delete, uri: "\(api)/owners/" + owner.id!.string!)
        request.headers["Authorization"] = "Basic " + "123:abc".toBase64()
        
        let response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status.statusCode, 200)
        XCTAssertEqual(response.contentType, "application/json; charset=utf-8")
        
        try Owner.deleteAll()
    }
    
    func testDeleteOwners() throws {
        let drop = try makeTestDroplet()
        var owner = try Owner(name: "John")
        try owner.save()
        
        let request = try Request(method: .delete, uri: "\(api)/owners/")
        request.headers["Authorization"] = "Basic " + "123:abc".toBase64()
        
        let response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status.statusCode, 200)
        XCTAssertEqual(response.contentType, "application/json; charset=utf-8")
        
        try Owner.deleteAll()
    }
    
}
