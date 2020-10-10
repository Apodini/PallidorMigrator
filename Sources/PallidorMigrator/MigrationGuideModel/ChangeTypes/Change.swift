//
//  Change.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

/// Abstract change
class Change : Changing {
    
    internal init(reason: String? = nil, object: ObjectType, target: TargetType, changeType: ChangeType = .nil) {
        self.reason = reason
        self.object = object
        self.target = target
        self.changeType = changeType
    }

    var reason : String?
    var object : ObjectType
    var target : TargetType
    var changeType : ChangeType = .nil
    
    private enum CodingKeys : CodingKey {
        case reason, object, target
    }
    
    private enum ObjectTypeDecodingError : Error {
        case failedToDecode
        case unsupported(msg: String)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
    
        reason = try? values.decode(String.self, forKey: .reason)
        target = try values.decode(TargetType.self, forKey: .target)
                
        if let value = try? values.decode(Method.self, forKey: .object){
            object = .method(value)
            try self.validate()
            return
        }
        
        if let value = try? values.decode(Endpoint.self, forKey: .object){
            object = .endpoint(value)
            try self.validate()
            return
        }
        
        if let value = try? values.decode(Model.self, forKey: .object){
            object = .model(value)
            try self.validate()
            return
        }
        
        if let value = try? values.decode(EnumModel.self, forKey: .object){
            object = .enum(value)
            try self.validate()
            return
        }
        
        
        throw ObjectTypeDecodingError.failedToDecode
    }
    
    func validate() throws {
        switch object {
        case .model(_):
            switch target {
            case .parameter:
                throw ObjectTypeDecodingError.unsupported(msg: "Change object `Model` cannot target `Parameter`")
            default:
                return
            }
        case .method(_):
            switch target {
            default:
                return
            }
        default:
            return
        }
    }
}
