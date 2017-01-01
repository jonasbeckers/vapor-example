//
//  IfNot.swift
//  vapor-example
//
//  Created by Jonas Beckers on 26/12/16.
//
//

import Foundation
import Leaf

public class Empty: BasicTag {
    
    public let name = "empty"
    
    public init() {}
    
    public func run(arguments: [Argument]) throws -> Node? {
        guard arguments.count == 1 else {
            throw If.Error.expectedSingleArgument(have: arguments)
        }
        
        return nil
    }
    
    public func shouldRender(stem: Stem, context: Context, tagTemplate: TagTemplate, arguments: [Argument], value: Node?) -> Bool {
        
        guard let value = arguments.first?.value?.nodeArray else {
            return false
        }
        
        return value.count == 0
    }
    
}
