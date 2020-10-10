//
//  RenameChange.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

/// Renaming change as stated in migration guide
class RenameChange : Change {
    
    /// name of the item before it was changed
    var originalId : String
    
    /// renamed item after changed
    var renamed : ContentType?
    
    private enum CodingKeys : String, CodingKey {
        case originalId = "original-id"
        case renamed
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.originalId = try container.decode(String.self, forKey: .originalId)
        self.renamed = try? container.decode(ContentType.self, forKey: .renamed)
        try super.init(from: decoder)
        
        self.changeType = .rename
    }
}
