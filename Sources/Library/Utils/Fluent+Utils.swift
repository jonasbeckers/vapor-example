//
//  Fluent+Utils.swift
//  vapor-example
//
//  Created by Jonas Beckers on 22/12/16.
//
//

import Fluent

extension Entity {
    
    static func deleteAll() throws {
        try Self.query().delete()
    }
    
}
