//
//  ChatController.swift
//  vapor-example
//
//  Created by Jonas Beckers on 27/12/16.
//
//

import Vapor
import Foundation
import Socks
import HTTP
import Auth

final class ChatController {
    
    let drop: Droplet
    var chat: Chat
    
    init(drop: Droplet) {
        self.drop = drop
        self.chat = Chat(name: "Random")
    }
    
    func index(_ request: Request) throws -> ResponseRepresentable {
        let user = try request.user()
        return try drop.view.make("chat", ["authenticated": true, "username": user.username, "channel": chat.name])
    }
    
    func chatSocket(request: Request, ws: WebSocket) throws {
        var username: String? = nil
        
        ws.onText = { ws, text in
            let json = try JSON(bytes: Array(text.utf8))
            
            if let u = json.object?["username"]?.string {
                username = u
                self.chat.connections[u] = ws
                try self.chat.userMessage("\(u) has joined.")
                
            }
            
            if let u = username, let m = json.object?["message"]?.string {
                try self.chat.send(username: u, message: m)
            }
        }
        
        ws.onClose = { ws, code, reason, clean in
            guard let u = username else {
                return
            }
            
            self.chat.connections.removeValue(forKey: u)
            try self.chat.userMessage("\(u) has left.")
        }
    }
    
}

extension WebSocket {
    
    func send(_ json: JSON) throws {
        let js = try json.makeBytes()
        try send(js.string())
    }
    
}
