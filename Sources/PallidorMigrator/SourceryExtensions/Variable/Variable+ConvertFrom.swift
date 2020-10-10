//
//  Variable+ConvertFrom.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation
import SourceryRuntime

extension WrappedVariable {
    
    /// unmodified version for `from()` method
    var unmodifiedFrom : String {
        get {
                              
            guard isMutable else {
                return ""
            }
            
            if(isEnum) {
                return enumInit
            }
            
            if(isTypeAlias && typeName.isPrimitiveType){
                return defaultInit
            }
            
            if(isCustomType && isArray) {
                return customArrayTypeInit
            }
            
            if(isCustomType) {
                return customTypeInit
            }
            
            if(isCustomInternalEnumType){
                return customInternalEnumInit
            }
            
            return defaultInit
        }
    }
    
    /// initializer string for enum type
    private var enumInit : String {
        "self.\(name) = \(typeName.isOptional ? String(typeName.name.dropLast()) : typeName.name)(from.\(name))"
    }
    
    /// initializer string for internal enum type
    private var customInternalEnumInit : String {
        "self.\(name) = \(typeName.name)(from.\(name))\(isOptional ? "" : "!")"
    }
    
    /// initializer string for custom types
    private var customTypeInit : String {
        "self.\(name) = \(typeName.isOptional ? typeName.name.unwrapped : typeName.name)(from.\(name))"
    }
    
    /// initializer string for custom array types
    private var customArrayTypeInit : String {
        "self.\(name) = from.\(name)\(isOptional ? "?" : "").map({ \("\(typeName.underlyingType)($0)!") })"
    }
    
    /// default initializer string
    private var defaultInit : String {
        "self.\(name) = from.\(name)"
    }
    
    /// replacement string for `from()` method
    func replacedFrom(_ name: String) -> String {
        "self.\(self.name) = \(name)"
    }
    
}
