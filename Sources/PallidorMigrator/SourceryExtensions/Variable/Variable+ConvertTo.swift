//
//  Variable+ConvertTo.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation
import SourceryRuntime

extension WrappedVariable {
    /// unmodified version of `to()` conversion
    var unmodifiedTo: String {
        self.isMutable ? (self.isArray && self.isCustomType ? self.customTypeArrayConvert : (self.isEnum || (self.isCustomType && !self.isTypeAlias) || self.isCustomInternalEnumType ? self.complexConvert : "\(self.name): self.\(self.name)")) : ""
    }
    
    /// conversion string of complex types
    private var complexConvert: String {
        "\(name): self.\(name)\(isOptional ? "?" : "").to()"
    }
    
    /// conversion string of complex array types
    private var customTypeArrayConvert: String {
        "\(name): self.\(name)\(isOptional ? "?" : "").map({ $0.to()! })"
    }
    
    /// Replace `to()` string of variable
    /// - Parameter name: name of variable which replaces this variable
    /// - Returns: replacement string
    func replacedTo(_ name: String) -> String {
        self.isMutable ? (self.isArray && self.isCustomType ? "\(name): \(name).map({ $0.to()! })" : (self.isEnum || (self.isCustomType && !self.isTypeAlias) || self.isCustomInternalEnumType ? "\(name): \(name).to()" : "\(name): self.\(self.name)")) : ""
    }
}
