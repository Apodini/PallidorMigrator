//
//  WrappedMethod.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation
import SourceryRuntime

/// Wrapped method of sourcery Method
class WrappedMethod : Modifiable {
    var annotation: Annotation?
    
    var id: String { self.shortName }
    
    var modified: Bool = false
    
    /// true if a parameter was replaced by a different type
    var paramsRequireJSContext = false
    
    func modify(change: Change) {
        self.modified = true
        
        switch change.changeType {
        case .add:
            handleAddChange(change: change as! AddChange)
            break
        case .rename:
            handleRenameChange(change: change as! RenameChange)
            break
        case .replace:
            handleReplaceChange(change: change as! ReplaceChange)
            break
        case .delete:
            handleDeleteChange(change: change as! DeleteChange)
            break
        default:
            print("not implemented")
        }
    }
    
    
    internal init(ignore: Bool, isInitializer: Bool, isRequired: Bool, isGeneric: Bool, isStatic: Bool, throws: Bool, name: String, definedInTypeName: WrappedTypeName? = nil, returnTypeName: WrappedTypeName, parameters: [WrappedMethodParameter]) {
        self.ignore = ignore
        self.isInitializer = isInitializer
        self.isRequired = isRequired
        self.isGeneric = isGeneric
        self.isStatic = isStatic
        self.`throws` = `throws`
        self.name = name
        self.definedInTypeName = definedInTypeName
        self.returnTypeName = returnTypeName
        self.parameters = parameters
    }
    
    convenience init(from: SourceryMethod) {
        self.init(ignore: from.annotations["ignore"] != nil, isInitializer: from.isInitializer, isRequired: from.isRequired, isGeneric: from.isGeneric, isStatic: from.isStatic, throws: from.throws, name: from.name, definedInTypeName: from.definedInTypeName != nil ? WrappedTypeName(from: from.definedInTypeName!) : nil, returnTypeName: WrappedTypeName(from: from.returnTypeName), parameters: from.parameters.map({WrappedMethodParameter(from: $0)}))
    }
    
    
    var ignore : Bool
    var isInitializer : Bool
    var isRequired: Bool
    var isGeneric: Bool
    var isStatic: Bool
    var `throws`: Bool
    var name: String
    var definedInTypeName: WrappedTypeName?
    var returnTypeName: WrappedTypeName
    var parameters: [WrappedMethodParameter]
    
    var getPersistentInitializer : (WrappedMethod) -> String = { m in m.name }
    
    lazy var nameToCall : () -> String = { () in
        self.shortName
    }
    
    lazy var apiMethodString : () -> String = { () in
        """
        \(self.signatureString) {
        \(self.parameterConversion() ?? "")
        return _\(self.definedInTypeName!.name).\(self.nameToCall())(\(self.parameters.map({$0.endpointCall()}).skipEmptyJoined(separator: ", ")))
        \(self.apiMethodResultMap)
        }
        """
    }
    
    lazy var parameterConversion : () -> String? = {
        self.paramsRequireJSContext ?
            """
            let context = JSContext()!
            \(self.parameters.map({$0.paramConversionString()}).skipEmptyJoined(separator: "\n"))
            """
            : self.parameters.map({$0.paramConversionString()}).skipEmptyJoined(separator: "\n")
    }
    
    lazy var parameterString : () -> String = { () in
        self.parameters.compactMap({$0.signatureString()}).skipEmptyJoined(separator: ", ")
    }
    
    lazy var mapString : (String) -> String? = { (type) in
        return type.isPrimitiveType ? nil :
            ( type.isArrayType ?
                """
                .map({$0.map({\(type.dropFirstAndLast())($0)!})})
                """
                :
                """
                .map({\(type)($0)!})
                """
            )
    }
}
