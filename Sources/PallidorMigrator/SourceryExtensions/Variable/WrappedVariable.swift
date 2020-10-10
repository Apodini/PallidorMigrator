//
//  WrappedVariable.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation
import SourceryRuntime

/// Variable wrapped SourceryVariable
class WrappedVariable: Modifiable {
    var annotation: Annotation?
    
    
    internal init(name: String, defaultValue: String? = nil, isMutable: Bool, isEnum: Bool, isCustomType: Bool, isArray: Bool, isCustomInternalEnumType: Bool, isOptional: Bool, isStatic: Bool, typeName: WrappedTypeName) {
        self.name = name
        self.defaultValue = defaultValue
        self.isMutable = isMutable
        self.isEnum = isEnum
        self.isCustomType = isCustomType
        self.isArray = isArray
        self.isCustomInternalEnumType = isCustomInternalEnumType
        self.isOptional = isOptional
        self.isStatic = isStatic
        self.typeName = typeName
    }
    
    convenience init(from: SourceryVariable) {
        self.init(name: from.name, defaultValue: from.defaultValue, isMutable: from.isMutable, isEnum: from.annotations["isEnumType"] != nil, isCustomType: from.annotations["isCustomType"] != nil, isArray: from.isArray, isCustomInternalEnumType: from.annotations["isCustomInternalEnumType"] != nil, isOptional: from.isOptional, isStatic: from.isStatic, typeName: WrappedTypeName(from: from.typeName))
    }
    
    /// name of variable
    var name: String
    /// default value of variable
    var defaultValue: String?
    /// true if variable is not a constant
    var isMutable: Bool
    /// true if variable is an enum type
    var isEnum: Bool
    /// true if variable is an custom type
    var isCustomType: Bool
    /// true if variable is an array type
    var isArray: Bool
    /// true if variable is an internal enum type
    var isCustomInternalEnumType: Bool
    /// true if variable is optional
    var isOptional: Bool
    /// true if variable is static
    var isStatic: Bool
    /// true if variable is a typealias
    var isTypeAlias: Bool {
        typeName.isTypeAlias
    }
    
    /// the type of the variable
    var typeName: WrappedTypeName
    
    /// Declaration string of variable
    lazy var declaration : () -> String = { () in
        "\(self.isCustomInternalEnumType ? "//sourcery: isCustomInternalEnumType\n" : "")\(self.isStatic ? "static " : "")\(self.isMutable ? "var" : "let") \(self.name) : \(self.typeName.name)\(self.defaultValue != nil && !self.modified ? " = \(self.defaultValue!)" :"")"
    }
    
    /// Initializer parameter string of variable
    lazy var initParam : () -> String = { () in
        "\(self.name): \(self.typeName.name)"
    }
    
    /// String of variable inside of initializer
    lazy var initBody : () -> String = { () in "self.\(self.name) = \(self.name)" }
    
    /// String of variable inside `to()` method
    lazy var convertTo : () -> String = { () in
        self.unmodifiedTo
    }
    
    /// String of variable inside `from()` method
    lazy var convertFrom : () -> String = { () in
        self.unmodifiedFrom
    }
    
    /// Adaption string of variable inside `to()` or `from()` method if variable was replaced
    lazy var replaceAdaption : (_ isFromConversion: Bool) -> String? = { b in nil }
    
    var id: String { self.name }
    
    var modified: Bool = false
    
    func modify(change: Change) {
        self.modified = true
        switch change.changeType {
        case .add:
            handleAddChange(change as! AddChange)
            break
        case .delete:
            handleDeletedChange(change as! DeleteChange)
            break
        case .replace:
            if change.target == .property {
                handleReplacedChange(change as! ReplaceChange)
            }
            if change.target == .signature {
                handleReplacedParentChange(change as! ReplaceChange)
            }
            break
        case .rename:
            handleRenameChange(change as! RenameChange)
            break
        default:
            fatalError("Variable: Modification not implemented")
        }
    }
}
