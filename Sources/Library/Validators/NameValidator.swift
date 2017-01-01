//
//  NameValidator.swift
//  vapor-example
//
//  Created by Jonas Beckers on 24/12/16.
//
//

import Foundation
import Vapor

public class Name: ValidationSuite {
    
    public static func validate(input value: String) throws {
        let evaluation = OnlyAlphanumeric.self && Count.min(2) && Count.max(30)
        try evaluation.validate(input: value)
    }
}
