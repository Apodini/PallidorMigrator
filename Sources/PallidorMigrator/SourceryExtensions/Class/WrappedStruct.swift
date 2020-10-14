//
//  WrappedStruct.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation
import SourceryRuntime

/// Wraps struct types of Sourcery
class WrappedStruct: Modifiable {
    var annotation: Annotation?
    
    var id: String {
        "/\(localName.replacingOccurrences(of: "API", with: "").replacingOccurrences(of: "_", with: "").lowercased())"
    }
    
    var modified: Bool = false
    
    func modify(change: Change) {
        self.modified = true
        
        switch change.changeType {
        case .replace:
            specialImports.insert("import JavaScriptCore")
            break
        case .rename:
            if case .signature = change.target, case .endpoint = change.object {
                handleEndpointRenameChange(change as! RenameChange)
            }
            break
        case .delete:
            if case .signature = change.target, case .endpoint = change.object {
                handleEndpointDeletedChange(change as! DeleteChange)
            }
            break
        default:
            print("API modify: not a replace or rename change.")
        }
        
        for m in methods {
            if case .method(let n) = change.object {
                if n.operationId == m.id {
                    m.modify(change: change)
                }
            }
        }
    }
    
    internal init(localName: String, variables: [WrappedVariable], methods: [WrappedMethod]) {
        self.localName = localName
        self.variables = variables
        self.methods = methods
    }
    
    convenience init(from: SourceryRuntime.Struct) {
        self.init(localName: from.localName.removePrefix, variables: from.variables.map({ WrappedVariable(from: $0) }), methods: from.methods.map({ WrappedMethod(from: $0) }))
    }
    
    /// contains additional imports besides Foundation if necessary
    var specialImports = Set<String>()
    /// name of struct
    var localName: String
    /// variables of struct
    var variables: [WrappedVariable]
    /// methods of struct
    var methods: [WrappedMethod]
}

extension WrappedStruct : NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        return WrappedStruct(localName: localName, variables: variables, methods: methods)
    }
}
