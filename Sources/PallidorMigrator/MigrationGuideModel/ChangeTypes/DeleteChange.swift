//
//  DeleteChange.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

/// Deletion change as stated in migration guide
class DeleteChange: Change {
    internal init(fallbackValue: ContentType? = nil, reason: String?, object: ObjectType, target: TargetType) {
        self.fallbackValue = fallbackValue
        super.init(reason: reason, object: object, target: target, changeType: .delete)
    }
    
    /// a fallback value to be put in place for deleted item
    var fallbackValue: ContentType?
    
    private enum CodingKeys: String, CodingKey {
        case fallbackValue = "fallback-value"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let value = try? container.decode(Variable.self, forKey: .fallbackValue) {
            self.fallbackValue = value
            try super.init(from: decoder)
            self.changeType = .delete
            return
        }
                
        if let value = try? container.decode(Model.self, forKey: .fallbackValue) {
            self.fallbackValue = value
            try super.init(from: decoder)
            self.changeType = .delete
            return
        }
        
        if let value = try? container.decode(EnumModel.Case.self, forKey: .fallbackValue) {
            self.fallbackValue = value
            try super.init(from: decoder)
            self.changeType = .delete
            return
        }
        
        self.fallbackValue = try container.decode(ContentType.self, forKey: .fallbackValue)
        try super.init(from: decoder)
        
        self.changeType = .delete
    }
}
