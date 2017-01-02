//
//  ChatCollection.swift
//  vapor-example
//
//  Created by Jonas Beckers on 28/12/16.
//
//


import Vapor
import Routing
import HTTP
import Turnstile
import TurnstileWeb
import Auth

class ChatCollection: RouteCollection {
    
    let drop: Droplet
    
    init(drop: Droplet) {
        self.drop = drop
    }
    
    typealias Wrapped = HTTP.Responder
    
    func build<Builder : RouteBuilder>(_ builder: Builder) where Builder.Value == Wrapped {
        let chatController = ChatController(drop: drop)
        
        builder.group("chat") { chatGroup in
            
            chatGroup.get(handler: chatController.index)
            chatGroup.socket("ws", handler: chatController.chatSocket)
            
        }
    }
    
}
