//
//  Method.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

/// represents a method content type
class Method : ContentType {
    
    /// operation identifier as stated in open api document
    var operationId : String
    /// top level route segment
    var definedIn : String
    /// content body as stated in open api document (no name required)
    var contentBody : Parameter?
    /// return value as stated in open api document (no name required)
    var returnValue : ReturnValue?
    
    private enum CodingKeys : String, CodingKey {
        case operationId = "operation-id"
        case definedIn = "defined-in"
        case returnValue
        case contentBody = "content-body"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.operationId = try container.decode(String.self, forKey: .operationId)
        self.definedIn = try container.decode(String.self, forKey: .definedIn)
        
        self.contentBody = try? container.decode(Parameter.self, forKey: .contentBody)
        
        
        self.returnValue = try? container.decode(ReturnValue.self, forKey: .returnValue)

        try super.init(from: decoder)
        
        self.id = "\(definedIn).\(operationId)"
    }
    
}
