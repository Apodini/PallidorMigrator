//
//  Variable.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

typealias Property = Variable
typealias Parameter = Variable
typealias ReturnValue = Variable

/// represents a variable, property, parameter and return value content type
class Variable: ContentType {
    /// identifier
    var name: String
    /// type of variable
    var type: String
    /// default value of variable
    var defaultValue: String?
    /// required as stated in open api document
    var required: Bool

    private enum CodingKeys: String, CodingKey {
        case type
        case name
        case required
        case isCustomType = "is-custom"
        case defaultValue = "default-value"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(String.self, forKey: .type)
        self.name = try container.decode(String.self, forKey: .name)
        self.required = (try? container.decode(Bool.self, forKey: .required)) ?? false
        self.defaultValue = try? container.decode(String.self, forKey: .defaultValue)

        self.type = "\(self.type)\(required ? "" : "?")"

        try super.init(from: decoder)

        self.id = name
    }
}
