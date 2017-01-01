//
//  ApiCommand.swift
//  vapor-example
//
//  Created by Jonas Beckers on 25/12/16.
//
//

import Vapor
import Console

public class TestCommmand: Command {
    
    public let id: String = "test"
    public let help: [String] = ["It prints some text nothing more"]
    public let console: ConsoleProtocol
    
    public init(console: ConsoleProtocol) {
        self.console = console
    }
    
    public func run(arguments: [String]) throws {
        console.print("This is a test", newLine: true)
    }
    
}
