//
//  ReplaceChange.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

/// Replace change as stated in migration guide
class ReplaceChange : Change {
    
    /// Identifier of replacement
    var replacementId : String
    /// Replacement item
    var replaced : ContentType?
    /// JS method to convert old type to new type
    var customConvert : String?
    /// JS method to convert new type to old type
    var customRevert : String?
    /// Type of replacement
    var type : String?
    
    private enum CodingKeys : String, CodingKey {
        case replacementId = "replacement-id"
        case customConvert = "custom-convert"
        case customRevert = "custom-revert"
        case type
        case replaced
    }
    
    private enum ReplacementDecodingError : Error {
        case missingConversion(reason: String)
        case unsupported(reason: String)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.replacementId = try container.decode(String.self, forKey: .replacementId)
        self.customConvert = try? container.decode(String.self, forKey: .customConvert)
        self.customRevert = try? container.decode(String.self, forKey: .customRevert)
        self.type = try? container.decode(String.self, forKey: .type)
        
        if let value = try? container.decode(Property.self, forKey: .replaced){
            self.replaced = value
        } else if let value = try? container.decode(Method.self, forKey: .replaced){
            self.replaced = value
        } else if let value = try? container.decode(Model.self, forKey: .replaced){
            self.replaced = value
        } else if let value = try? container.decode(EnumModel.self, forKey: .replaced){
            self.replaced = value
        } else {
            let value = try? container.decode(ContentType.self, forKey: .replaced)
            self.replaced = value
        }
        
        try super.init(from: decoder)
        
        try validate()
        
        self.changeType = .replace
    }
    
    // TODO: refactor - dont make sense right now
    override func validate() throws {
        
        if target == .returnValue && customRevert == nil {
            throw ReplacementDecodingError.missingConversion(reason: "Target return value requires conversion JS-method (revert): `function conversion(replaced) { JSON.stringify( { replacement... } ) }`")
        }
        
        if type != nil && target != .returnValue && (customConvert == nil || customRevert == nil) {
            throw ReplacementDecodingError.missingConversion(reason: "Custom type requires two conversion JS-methods: `function conversion(replaced) { JSON.stringify( { replacement... } ) }`")
        }
    }
    
}
