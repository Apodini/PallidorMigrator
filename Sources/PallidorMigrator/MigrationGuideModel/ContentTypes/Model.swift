//
//  Model.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

/// represents a schema model content type
class Model : ContentType {
    
    /// identifier of model
    var name: String
    
    private enum CodingKeys : String, CodingKey {
        case name
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        
        try super.init(from: decoder)
        self.id = name
    }
}
