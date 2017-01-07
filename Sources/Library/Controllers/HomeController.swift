//
//  LoginController.swift
//  vapor-example
//
//  Created by Jonas Beckers on 23/12/16.
//
//

import Vapor
import Auth
import HTTP
import Cookies
import Turnstile
import TurnstileCrypto
import TurnstileWeb
import Fluent
import Foundation

final class Hometroller {
    
    let drop: Droplet
    let log: LogProtocol
    
    var google: Google?
    var facebook: Facebook?
    
    init(drop: Droplet) {
        self.drop = drop
        self.google = nil
        self.facebook = nil
        self.log = drop.log.self
        initRealms()
    }
    
    func initRealms() {
        if let google_client_id = drop.config["app", "google_client_key"]?.string, let google_client_secret = drop.config["app", "google_client_secret"]?.string {
            google = Google(clientID: google_client_id, clientSecret: google_client_secret)
        } else {
            log.warning("Google client key and/or secret not found")
        }
        if let facebook_client_id = drop.config["app", "facebook_client_key"]?.string, let facebook_client_secret = drop.config["app", "facebook_client_secret"]?.string {
            facebook = Facebook(clientID: facebook_client_id, clientSecret: facebook_client_secret)
        } else {
            log.warning("Facebook client key and/or secret not found")
        }
    }
    
    func dashBoard(_ request: Request) throws -> ResponseRepresentable {
        let user = try? request.user()
        
        var dashboardView = try Node(node: ["authenticated": user != nil])
        dashboardView["account"] = try user?.makeNode()
        
        log.info("Opening dashboard for \(user?.username ?? "not logged in")")
        
        return try drop.view.make("index", dashboardView)
    }
    
    func loginPage(_ request: Request) throws -> ResponseRepresentable {
        return try drop.view.make("login")
    }
    
    func login(_ request: Request) throws -> ResponseRepresentable {
        if let credentials = getCredentials(request: request) {
            do {
                try request.auth.login(credentials, persist: true)
                log.info("Succesfull login for \(credentials.username)")
                return Response(redirect: "/")
            } catch {
                log.info("Incorrect password or username for \(credentials.username)")
                return try drop.view.make("login", ["message": "Invalid username or password"])
            }
        } else {
            log.info("Missing username or password for login")
            return try drop.view.make("login", ["message": "Missing username or password"])
        }
    }
    
    func googleLogin(_ request: Request) throws -> ResponseRepresentable {
        if let google = google {
            let state = URandom().secureToken
            let response = Response(redirect: google.getLoginLink(redirectURL: request.baseURL + "/login/google/consumer", state: state).absoluteString)
            response.cookies["OAuthState"] = state
            return response
        } else {
            log.error("Google service unavailable")
            throw Abort.custom(status: .serviceUnavailable, message: "Google login currently unavailable")
        }
    }
    
    func googleLoginConsumer(_ request: Request) throws -> ResponseRepresentable {
        if let google = google {
            guard let state = request.cookies["OAuthState"] else {
                return Response(redirect: "/login")
            }
            
            let account = try google.authenticate(authorizationCodeCallbackURL: request.uri.description, state: state) as! GoogleAccount
            try request.auth.login(account)
            
            log.info("Succesfull google login for \(account.uniqueID)")
            
            return Response(redirect: "/")
        } else {
            log.error("Google service unavailable")
            throw Abort.custom(status: .serviceUnavailable, message: "Google login currently unavailable")
        }
    }
    
    func facebookLogin(_ request: Request) throws -> ResponseRepresentable {
        if let facebook = facebook {
            let state = URandom().secureToken
            let response = Response(redirect: facebook.getLoginLink(redirectURL: request.baseURL + "/login/facebook/consumer", state: state).absoluteString)
            response.cookies["OAuthState"] = state
            return response
        } else {
            log.error("Facebook service unavailable")
            throw Abort.custom(status: .serviceUnavailable, message: "Facebook login currently unavailable")
        }
    }
    
    func facebookLoginConsumer(_ request: Request) throws -> ResponseRepresentable {
        if let facebook = facebook {
            guard let state = request.cookies["OAuthState"] else {
                return Response(redirect: "/login")
            }
            
            let account = try facebook.authenticate(authorizationCodeCallbackURL: request.uri.description, state: state) as! FacebookAccount
            try request.auth.login(account)
            
            log.info("Succesfull facebook login for \(account.uniqueID)")
            
            return Response(redirect: "/")
        } else {
            log.error("Facebook service unavailable")
            throw Abort.custom(status: .serviceUnavailable, message: "Google login currently unavailable")
        }
    }
    
    func registerPage(_ request: Request) throws -> ResponseRepresentable {
        try request.auth.logout()
        return try drop.view.make("register")
    }
    
    func register(_ request: Request) throws -> ResponseRepresentable {
        if let credentials = getCredentials(request: request) {
            do {
                _ = try User.register(credentials: credentials)
                try request.auth.login(credentials)
                
                log.info("Succesfull register for \(credentials.username)")
                
                return Response(redirect: "/")
            } catch let error as TurnstileError {
                log.error("Error while registering for user \(credentials.username) with error \(error.description)")
                return try drop.view.make("register", ["message": error.description])
            }
        }
        
        log.info("Missing username or password register")
        
        return try drop.view.make("register", ["message": "Missing username or password"])
    }
    
    func logout(_ request: Request) throws -> ResponseRepresentable {
        log.info("Logging out user \(try request.auth.user().uniqueID)")
        
        try request.auth.logout()
        
        return Response(redirect: "/")
    }
    
    private func getCredentials(request: Request) -> UsernamePassword? {
        guard let username = request.formURLEncoded?["username"]?.string, let password = request.formURLEncoded?["password"]?.string else {
            return nil
        }
        
        return UsernamePassword(username: username, password: password)
    }
    
}
