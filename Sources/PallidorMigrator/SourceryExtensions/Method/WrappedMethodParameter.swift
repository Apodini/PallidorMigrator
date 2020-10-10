//
//  WrappedMethodParameter.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation
import SourceryRuntime

/// Wrapped parameter of sourcery MethodParameter
class WrappedMethodParameter : Modifiable {
    var annotation: Annotation?
    
    var id: String {
        self.name
    }
    
    var modified: Bool = false
    
    func modify(change: Change) {
        self.modified = true
        switch change.changeType {
        case .add:
            handleAddChange(change as! AddChange)
            break
        case .replace:
            handleReplacementChange(change as! ReplaceChange)
            break
        case .rename:
            handleRenameChange(change as! RenameChange)
            break
        case .delete:
            handleDeleteChange(change as! DeleteChange)
            break
        default:
            print("not implemented")
        }
    }
    
    internal init(name: String, isOptional: Bool, typeName: WrappedTypeName, actualTypeName: WrappedTypeName?, defaultValue: String?) {
        self.name = name
        self.isOptional = isOptional
        self.typeName = typeName
        self.actualTypeName = actualTypeName
        self.defaultValue = defaultValue
    }
    
    convenience init(from: MethodParameter) {
        self.init(name: from.name, isOptional: from.isOptional, typeName: WrappedTypeName(from: from.typeName), actualTypeName: from.actualTypeName != nil ? WrappedTypeName(from: from.actualTypeName!) : nil, defaultValue: from.defaultValue)
    }
    
    /// name of parameter
    var name: String
    /// true if parameter is optional
    var isOptional: Bool
    /// type of parameter
    var typeName: WrappedTypeName
    /// actual type of parameter (if type alias)
    var actualTypeName: WrappedTypeName?
    /// default value of parameter if available
    var defaultValue: String?
    /// true if default value is set
    var hasDefaultValue: Bool {
        defaultValue != nil
    }
    
    /// String representation of parameter in method signature
    lazy var signatureString : () -> String = { () in
        "\(self.name): \(self.actualTypeName!.name) \(self.hasDefaultValue ? " = \(self.defaultValue!)" :"")"
    }
    
    /// String for parameter conversion
    lazy var paramConversionString : () -> String = { () in "" }
    
    /// String representation of parameter in calling the api method
    lazy var endpointCall : () -> String = {
        let isPrimitive = self.name != "element" || self.typeName.name.isPrimitiveType
        
        guard !isPrimitive else {
            return "\(self.name): \(self.name)"
        }
        
        let optional = self.isOptional ? "?" : ""
        
        return self.name == "element" && self.typeName.isArray ?
            "element: element\(optional).map({$0.to()!})" : (self.name == "element" ? "element: element\(optional).to()!" : "\(self.name): \(self.name)")
    }
}
