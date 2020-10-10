//
//  MethodParameter+Modification.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

extension WrappedMethodParameter {
    
    /// handle added a method parameter
    /// - Parameter change: AddChange affecting this parameter
    func handleAddChange(_ change: AddChange) {
        switch change.target {
        case .parameter:
            let param = change.added.first(where: {$0.id == self.name})! as! Parameter
            self.defaultValue = param.defaultValue!
            
            signatureString = { () in
                "\(self.name): \(self.actualTypeName != nil ? self.actualTypeName!.name : self.typeName.name)\(self.isOptional ? "" : "?") = nil"
            }
            
            //only content type is complex -> query & path params must be primitives
            self.endpointCall = { () in
                "\(self.name): \(self.name) ?? \(TypeConversion.getDefaultValueInit(type: self.typeName.name, defaultValue: self.defaultValue!))"
            }
            break
        case .contentBody:
            let element = change.added.first! as! Parameter
            if !self.typeName.isPrimitiveType {
                self.paramConversionString = { () in
                    """
                    var \(self.id) = \(self.id)
                    
                    if \(self.id) == nil {
                        let \(self.id)Tmp : String? = \"""
                            \(element.defaultValue!)
                        \"""
                    
                        \(self.id) = \(TypeConversion.getDecodingString(id: "\(self.id)Tmp", type: self.typeName.name))
                    }
                    """
                }

                self.endpointCall = { () in
                    self.typeName.isArray ?
                        "element: element!.map({$0.to()!})" : "element: element!.to()!"
                }
            } else {
                self.paramConversionString = { () in
                    TypeConversion.getDefaultValueInit(type: self.typeName.actualName, defaultValue: element.defaultValue!)
                }
                self.endpointCall = { () in
                    self.typeName.isArray ?
                        "element: element.map({$0.to()!})" : "element: element!"
                }
            }
            self.signatureString = { () in
                "\(self.name): \(self.typeName.name)? = nil"
            }
            break
        default:
            print("MethodParameter: AddChange unknown target.")
        }
        
    }
    
    /// handle renaming a method parameter
    /// - Parameter change: RenameChange affecting this parameter
    func handleRenameChange(_ change: RenameChange) {
        self.name = change.originalId
        self.endpointCall = { () in
            "\(change.renamed!.id!): \(self.name)"
        }
    }
    
    /// handle deleting a method parameter
    /// - Parameter change: DeleteChange affecting this parameter
    func handleDeleteChange(_ change: DeleteChange) {
        self.endpointCall = { () in "" }
    }
    
    /// handle replacing a method parameter
    /// - Parameter change: ReplaceChange affecting this parameter
    func handleReplacementChange(_ change: ReplaceChange) {
        switch change.target {
        case .parameter:
            let replaced = change.replaced as! Parameter
            
            self.paramConversionString = { () in
                """
                context.evaluateScript(\"""\n\(change.customConvert!)\n\""")
                
                let \(self.id)Encoded = \(TypeConversion.getEncodingString(id: self.id, type: self.typeName.name, required: replaced.required))
                
                let \(change.replacementId)Tmp = context.objectForKeyedSubscript("conversion").call(withArguments: [\(self.id)Encoded])?.toString()
                
                let \(change.replacementId) = \(TypeConversion.getDecodingString(id: "\(change.replacementId)Tmp", type: change.type!))
                """
            }
            
            //only content type is complex -> query & path params must be primitives
            self.endpointCall = { () in
                "\(change.replacementId): \(change.replacementId)"
            }
            break
        case .contentBody:
            let replaced = change.replaced as! Parameter
            self.paramConversionString = { () in
                """
                context.evaluateScript(\"""\n\(change.customConvert!)\n\""")
                
                let \(self.id)Encoded = \(TypeConversion.getEncodingString(id: self.id, type: self.typeName.name, required: replaced.required))
                
                let \(self.id)Tmp = context.objectForKeyedSubscript("conversion").call(withArguments: [String(data: \(self.id)Encoded, encoding: .utf8)!])?.toString()
                
                let \(self.id) = \(TypeConversion.getDecodingString(id: "\(self.id)Tmp", type: change.type!))
                """
            }

            self.endpointCall = { () in
                self.typeName.isArray ?
                    "element: element.map({$0.to()!})" : "element: element.to()!"
            }
            self.signatureString = { () in
                "\(self.name): \(replaced.type)"
            }
            break
        default:
            break
        }
    }
        
}
