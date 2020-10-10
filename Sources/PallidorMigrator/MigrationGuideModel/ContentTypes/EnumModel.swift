//
//  EnumModel.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

/// represents an enum content type
class EnumModel : ContentType {
    
    /// represents an enum case content type
    class Case : ContentType {
        var `case` : String
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.case = try container.decode(String.self, forKey: .case)
            try super.init(from: decoder)
            super.id = self.case
        }
        
        init(case: String) {
            self.case = `case`
            super.init()
            super.id = self.case
        }
        
        private enum CodingKeys : String, CodingKey {
            case `case`
        }
    }
    
    internal init(enumName: String, cases: [Case] = [Case]()) {
        self.enumName = enumName
        self.cases = cases
        super.init()
    }
    
    /// enum identifier
    var enumName : String
    /// enum primitive type (e.g. String)
    var type : String?
    /// list of enum cases
    var cases : [Case] = [Case]()
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.enumName = try container.decode(String.self, forKey: .enumName)
        self.type = try? container.decode(String.self, forKey: .type)
        
        let cases = try? container.nestedUnkeyedContainer(forKey: .cases)
        
        if var caseContainer = cases {
            while !caseContainer.isAtEnd {
                let value = try caseContainer.decode(String.self)
                self.cases.append(EnumModel.Case(case: value))
            }
        }
        
        try super.init(from: decoder)
        self.id = enumName
    }
    
    private enum CodingKeys : String, CodingKey {
        case cases
        case enumName = "enum-name"
        case type
    }
    
}
