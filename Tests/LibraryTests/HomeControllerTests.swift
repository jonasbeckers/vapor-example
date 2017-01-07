//
//  HomeTests.swift
//  vapor-example
//
//  Created by Jonas Beckers on 26/12/16.
//
//

import XCTest
import Vapor
import HTTP
import Cookies
@testable import Library

class HomeControllerTests: XCTestCase {
    
    static var allTests : [(String, (HomeControllerTests) -> () throws -> Void)] {
        return [
            ("testDashboardNotLoggedIn", testDashboardNotLoggedIn),
            ("testRegisterPage", testRegisterPage),
            ("testRegisterMissingUsername", testRegisterMissingUsername),
            ("testRegister", testRegister),
            ("testLogout", testLogout),
            ("testLoginPage", testLoginPage),
            ("testLoginMissingPassword", testLoginMissingPassword),
            ("testLoginWrongCredentials", testLoginWrongCredentials),
            ("testLogin", testLogin),
        ]
    }
    
    func testDashboardNotLoggedIn() throws {
        let drop = try makeTestDroplet()
        
        let expected = try drop.view.make("index").makeBytes()
        
        let request = try Request(method: .get, uri: base)
        let response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status.statusCode, 200)
        XCTAssertEqual(response.body.bytes!, expected)
    }
    
    func testRegisterPage() throws {
        let drop = try makeTestDroplet()
        
        let expected = try drop.view.make("register").makeBytes()
        
        let request = try Request(method: .get, uri: "\(base)/register")
        let response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status.statusCode, 200)
        XCTAssertEqual(response.body.bytes!, expected)
    }
    
    func testRegisterMissingUsername() throws {
        let drop = try makeTestDroplet()
        
        let expected = try drop.view.make("register", ["message": "Missing username or password"]).makeBytes()
        
        let node = try Node(node:["password": "123"])
        let json = JSON(node)
        let body = try Body(json)
        let request = try Request(method: .post, uri: "\(base)/register", body: body)
        let response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status.statusCode, 200)
        XCTAssertEqual(response.body.bytes!, expected)
    }
    
    func testRegister() throws {
        let drop = try makeTestDroplet()
        
        let body = Body("username=tom&password=123")
        let request = try Request(method: .post, uri: "\(base)/register", body: body)
        request.headers["Content-type"] = "application/x-www-form-urlencoded"
        let response = try drop.respond(to: request)
        
        let user = try User.query().filter("username", "tom").first()
        
        XCTAssertNotNil(user)
        XCTAssertEqual(response.status.statusCode, 302)
        
        try User.deleteAll()
    }
    
    func testLogout() throws {
        let drop = try makeTestDroplet()
        
                let body = Body("username=tom&password=123")
        let registerRequest = try Request(method: .post, uri: "\(base)/register", body: body)
        registerRequest.headers["Content-type"] = "application/x-www-form-urlencoded"
        _ = try drop.respond(to: registerRequest)
        

        let loginRequest = try Request(method: .post, uri: "\(base)/login", body: body)
        loginRequest.headers["Content-type"] = "application/x-www-form-urlencoded"

        let loginResponse = try drop.respond(to: loginRequest)
        XCTAssertEqual(loginResponse.status.statusCode, 302)
        
        let request = try Request(method: .post, uri: "\(base)/logout")
        let response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status.statusCode, 302, try! response.body.bytes!.string())
        
        try User.deleteAll()
    }
    
    func testLoginPage() throws {
        let drop = try makeTestDroplet()
        
        let expected = try drop.view.make("login").makeBytes()
        
        let request = try Request(method: .get, uri: "\(base)/login")
        let response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status.statusCode, 200)
        XCTAssertEqual(response.body.bytes!, expected)
    }
    
    func testLoginMissingPassword() throws {
        let drop = try makeTestDroplet()
        
        let expected =  try drop.view.make("login", ["message": "Missing username or password"]).makeBytes()
        
        let body = Body("username=tom")
        let request = try Request(method: .post, uri: "\(base)/login", body: body)
        request.headers["Content-type"] = "application/x-www-form-urlencoded"
        let response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status.statusCode, 200)
        XCTAssertEqual(response.body.bytes!, expected)
    }
    
    func testLoginWrongCredentials() throws {
        let drop = try makeTestDroplet()
        
        let expected = try drop.view.make("login", ["message": "Invalid username or password"]).makeBytes()
        
        let body = Body("username=doesnotexist&password=nothing")
        let request = try Request(method: .post, uri: "\(base)/login", body: body)
        request.headers["Content-type"] = "application/x-www-form-urlencoded"
        let response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status.statusCode, 200)
        XCTAssertEqual(response.body.bytes!, expected)
    }
    
    func testLogin() throws {
        let drop = try makeTestDroplet()
        
        let bodyLogin = Body("username=tom&password=123")
        let registerRequest = try Request(method: .post, uri: "\(base)/register", body: bodyLogin)
        registerRequest.headers["Content-type"] = "application/x-www-form-urlencoded"
        _ = try drop.respond(to: registerRequest)

        let logoutRequest = try Request(method: .post, uri: "\(base)/logout")
        _ = try drop.respond(to: logoutRequest)
        
        let body = Body("username=tom&password=123")
        let request = try Request(method: .post, uri: "\(base)/login", body: body)
        request.headers["Content-type"] = "application/x-www-form-urlencoded"
        let response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status.statusCode, 302)
        
        try User.deleteAll()
    }
    
}
