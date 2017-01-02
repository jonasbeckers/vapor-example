//
//  User.swift
//  vapor-example
//
//  Created by Jonas Beckers on 23/12/16.
//
//

import Vapor
import Auth
import TurnstileWeb
import Turnstile
import TurnstileCrypto
import HTTP

public final class User: Model {
    
    public var exists: Bool = false
    
    public var id: Node?
    var username: String
    var password = ""
    var facebookID = ""
    var googleID = ""
    var apiKeyID = URandom().secureToken
    var apiKeySecret = URandom().secureToken
    
    init(credentials: UsernamePassword) {
        self.username = credentials.username
        self.password = BCrypt.hash(password: credentials.password)
    }
    
    init(credentials: FacebookAccount) {
        self.username = "fb" + credentials.uniqueID
        self.facebookID = credentials.uniqueID
    }
    
    init(credentails: GoogleAccount) {
        self.username = "goog" + credentails.uniqueID
        self.googleID = credentails.uniqueID
    }
    
    required public init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        username = try node.extract("username")
        password = try node.extract("password")
        facebookID = try node.extract("facebook_id")
        googleID = try node.extract("google_id")
        apiKeyID = try node.extract("api_key_id")
        apiKeySecret = try node.extract("api_key_secret")
    }
    
    public func makeNode(context: Context) throws -> Node {
        return try Node(node: ["id": id, "username": username, "password": password, "facebook_id": facebookID, "google_id": googleID, "api_key_id": apiKeyID, "api_key_secret": apiKeySecret])
    }
    
}

extension User {
    
    public static func prepare(_ database: Database) throws {
        try database.create("users") { table in
            table.id()
            table.string("username", unique: true)
            table.string("password")
            table.string("facebook_id")
            table.string("google_id")
            table.string("api_key_id")
            table.string("api_key_secret")
        }
    }
    
    public static func revert(_ database: Database) throws {
        try database.delete("users")
    }
    
}

extension User: Auth.User {
    
    public static func authenticate(credentials: Credentials) throws -> Auth.User {
        var user: User?
        
        switch credentials {
        case let credentials as UsernamePassword:
            let fetchedUser = try User.query().filter("username", credentials.username).first()
            if let password = fetchedUser?.password, password != "", (try? BCrypt.verify(password: credentials.password, matchesHash: password)) == true {
                user = fetchedUser
            }
        case let credentials as Identifier:
            user = try User.find(credentials.id)
        case let credentials as FacebookAccount:
            if let existing = try User.query().filter("facebook_id", credentials.uniqueID).first() {
                user = existing
            } else {
                user = try User.register(credentials: credentials) as? User
            }
        case let credentials as GoogleAccount:
            if let existing = try User.query().filter("google_id", credentials.uniqueID).first() {
                user = existing
            } else {
                user = try User.register(credentials: credentials) as? User
            }
        case let credentials as APIKey:
            user = try User.query().filter("api_key_id", credentials.id).filter("api_key_secret", credentials.secret).first()
        default:
            throw UnsupportedCredentialsError()
        }
        
        if let user = user {
            return user
        } else {
            throw IncorrectCredentialsError()
        }
    }
    
    public static func register(credentials: Credentials) throws -> Auth.User {
        var newUser: User
        
        switch credentials {
        case let credentials as UsernamePassword:
            newUser = User(credentials: credentials)
        case let credentials as FacebookAccount:
            newUser = User(credentials: credentials)
        case let credentials as GoogleAccount:
            newUser = User(credentails: credentials)
        default:
            throw UnsupportedCredentialsError()
        }
        
        if try User.query().filter("username", newUser.username).first() == nil {
            try newUser.save()
            return newUser
        } else {
            throw AccountTakenError()
        }
    }
    
}

extension Request {
    
    func user() throws -> User {
        guard let user = try self.auth.user() as? User else {
            throw "Invalid user type"
        }
        return user
    }
    
}

extension String: Error {}
