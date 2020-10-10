//
//  Enum+Modification.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

extension WrappedEnum {
    
    /// handle replacing the parent of an internal enum
    /// - Parameter change: ReplaceChange affecting this internal enum
    internal func handleReplacedParentChange(change: ReplaceChange) {
        self.defaultInternal = {
            """
            public enum \(self.localName) : \(self.inheritedTypes.mapJoined(separator: ", ")) {
                \(self.casesString)
            }
            """
        }
    }
    
    /// handle replacing an enum
    /// - Parameter change: ReplaceChange affecting this enum
    internal func handleReplacedChange(change: ReplaceChange) {
        
        let replaceEnumType = (change.replaced as! EnumModel).type != nil ? (change.replaced as! EnumModel).type! : "String"
        
        self.specialImports.insert("import JavaScriptCore")
        
        self.externalEnum = {
            """
            \(self.casesString)
            
            func to() -> _\(change.replacementId)? {
                let context = JSContext()!
                context.evaluateScript(\"""
                \(change.customConvert!)
                \""")
                let toTmp = context.objectForKeyedSubscript("conversion").call(withArguments: [self.rawValue])?.toString()
                return _\(change.replacementId)(rawValue: \(replaceEnumType == "String" ? "toTmp!" : "Int(toTmp!)!" ))
            }
            
            init?(_ from: _\(change.replacementId)?) {
                if let from = from {
                    let context = JSContext()!
                    context.evaluateScript(\"""
                    \(change.customRevert!)
                    \""")
                    let fromTmp = context.objectForKeyedSubscript("conversion").call(withArguments: [from.rawValue])?.toString()
                    self.init(rawValue: \(self.inheritedTypes[0] == "String" ? "fromTmp!" : "Int(fromTmp!)!"))
                } else {
                    return nil
                }
            }
            
            """
        }
    }
    
    /// handle renaming an enum
    /// - Parameter change: RenameChange affecting this enum
    internal func handleRenameChange(change: RenameChange) {
        
        self.localName = change.originalId
        
        if case let .enum(model) = change.object {
            self.externalEnum = {
                """
                \(self.casesString)
                
                func to() -> _\(model.enumName)? {
                    _\(model.enumName)(rawValue: self.rawValue)
                }
                
                init?(_ from: _\(model.enumName)?) {
                    if let from = from {
                        self.init(rawValue: from.rawValue)
                    } else {
                        return nil
                    }
                }
                
                """
            }
        }
    }
    
    /// handle deleting an enum
    /// - Parameter change: DeleteChange affecting this enum
    internal func handleDeletedChange(change: DeleteChange) {
        switch change.target {
        case .case:
            if let c = self.cases.first(where: { (self.isOfType && $0.name == change.fallbackValue!.id!.lowerFirst) || $0.name == change.fallbackValue!.id }) {
                c.modify(change: change)
            }
            break
        case .signature:
            self.annotation = .unavailable(msg: "Enum was removed in API version xxx")
            self.defaultInternal = {
                """
                \(self.annotation!)
                public enum \(self.localName) : \(self.inheritedTypes.mapJoined(separator: ", ")) { }
                """
            }
            self.externalEnum = { () in "\(self.casesString)" }
            break
        default:
            fatalError("Enum: change type not implemented")
        }
    }
}
