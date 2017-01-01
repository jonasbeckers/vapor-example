//
//  Chat.swift
//  vapor-example
//
//  Created by Jonas Beckers on 28/12/16.
//
//

import Foundation
import Vapor

class Chat {
    
    let name: String
    var connections: [String: WebSocket]
    
    var users: Int {
        return connections.count
    }
    
    init(name: String) {
        self.name = name
        self.connections = [:]
    }
    
    func userMessage(_ message: String) throws {
        try send(username: "Bot", message: message)
    }
    
    func send(username: String, message: String) throws {
        let json = try JSON(node: ["username": username, "message": message])
        
        for (user, socket) in connections {
            
            if username == user {
                continue
            } else {
                try socket.send(json)
            }
        }
    }
    
}
