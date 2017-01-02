//
//  Request+Utils.swift
//  vapor-example
//
//  Created by Jonas Beckers on 31/12/16.
//
//

import HTTP

extension Request {
    
    var baseURL: String {
        return uri.scheme + "://" + uri.host + (uri.port == nil ? "" : ":\(uri.port!)")
    }
    
}
