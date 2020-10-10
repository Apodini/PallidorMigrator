//
//  AddChange.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

/// Adding change as stated in migration guide
class AddChange: Change {
    internal init(added: [ContentType], reason: String?, object: ObjectType, target: TargetType) {
        self.added = added
        super.init(reason: reason, object: object, target: target, changeType: .add)
    }
    
    /// list of additional items
    var added: [ContentType]
    
    private enum CodingKeys: String, CodingKey {
        case added = "added"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.added = [ContentType]()
        
        var addedContainer = try container.nestedUnkeyedContainer(forKey: .added)
        
        while !addedContainer.isAtEnd {
            if let value = try? addedContainer.decode(Variable.self) {
                self.added.append(value)
                continue
            }
            if let value = try? addedContainer.decode(ContentType.self) {
                self.added.append(value)
            }
        }
        
        
        try super.init(from: decoder)
        self.changeType = .add
    }
}
