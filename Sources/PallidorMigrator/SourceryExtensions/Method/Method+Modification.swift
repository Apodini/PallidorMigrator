//
//  Method+Modification.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

extension WrappedMethod {
    /// handle renaming a method
    /// - Parameter change: RenameChange affecting this method
    func handleRenameChange(change: RenameChange) {
        switch change.object {
        case .method:
            switch change.target {
            case .signature:
                let newName = self.shortName
                self.name = self.name.replacingOccurrences(of: newName, with: change.originalId)
                self.nameToCall = { () in
                    newName
                }
                break
            case .parameter:
                let renamedParam = self.parameters.first(where: { $0.name == change.renamed!.id })!
                renamedParam.modify(change: change)
                break
            default:
                print("not implemented")
            }
            break
        case .endpoint(let ep):
            apiMethodString = { () in
                """
                \(self.signatureString) {
                \(self.parameterConversion() ?? "")
                return _\(Endpoint.endpointName(from: ep.id!)).\(self.nameToCall())(\(self.parameters.map({ $0.endpointCall() }).skipEmptyJoined(separator: ", ")))
                \(self.apiMethodResultMap)
                }
                """
            }
            break
        default:
            break
        }
    }
    
    /// handle deleting a method
    /// - Parameter change: DeleteChange affecting this method
    func handleDeleteChange(change: DeleteChange) {
        switch change.target {
        case .parameter,
             .contentBody:
            let deletedParam = createMethodParameter(param: change.fallbackValue as! Parameter)
            if change.target == .contentBody {
                deletedParam.name = "element"
            }
            deletedParam.modify(change: change)
            let insertIndex = self.parameters.firstIndex(where: { $0.name > deletedParam.name || $0.name == "element" || $0.name == "authorization" })!
            self.parameters.insert(deletedParam, at: insertIndex)
            break
        case .signature:
            self.annotation = .unavailable(msg: "This method was removed in API version: xxx")
            apiMethodString = { () in
                """
                \(self.annotation!.description)
                \(self.signatureString) {
                    fatalError("method unavailable")
                }
                """
            }
            break
        default:
            print("(Method) Delete Change target not implemented")
        }
    }
    
    /// handle adding a method parameter or content body
    /// - Parameter change: AddChange affecting this method
    func handleAddChange(change: AddChange) {
        switch change.target {
        case .parameter:
            for addition in change.added {
                let param = addition as! Parameter
                self.parameters.first(where: { $0.id == param.id })!.modify(change: change)
            }
            break
        case .contentBody:
            let body = self.parameters.first(where: { $0.name == "element" })
            body!.modify(change: change)
            break
        default:
            
            print("not implemented")
        }
    }
    
    /// handle replacing a method
    /// - Parameter change: ReplaceChange affecting this method
    func handleReplaceChange(change: ReplaceChange) {
        switch change.target {
        case .parameter:
            let replaceIndex = self.parameters.firstIndex(where: { $0.id == change.replacementId })
            let original = createMethodParameter(param: change.replaced! as! Parameter)
            original.modify(change: change)
            self.parameters[replaceIndex!] = original
            self.paramsRequireJSContext = true
            break
        case .returnValue:
            let returnValue = change.replaced! as! ReturnValue
            self.returnTypeName = WrappedTypeName(name: returnValue.type, actualName: returnValue.type, isOptional: false, isArray: returnValue.type.isArrayType, isVoid: false, isPrimitive: returnValue.type.isPrimitiveType)
            self.mapString = mapStringFunction(change: change)
            break
        case .contentBody:
            let element = self.parameters.first(where: { $0.name == "element" })
            element!.modify(change: change)
            self.paramsRequireJSContext = true
            break
        case .signature:
            replaceMethod(change: change)
            break
        case .property:
            fatalError("Property can not be target of a method migration")
        case .case:
            fatalError("Case can not be target of a method migration")
        }
    }
    
    /// Replacing a method
    /// - Parameter change: ReplaceChange affecting this method
    private func replaceMethod(change: ReplaceChange) {
        let method = change.replaced as! Method
        
        let ownRoute = Endpoint.routeName(from: self.definedInTypeName!.actualName)
        
        if method.definedIn != ownRoute {
            let codeStore = CodeStore.getInstance()
            let changeMethod = codeStore.getMethod(method.operationId)!
            changeMethod.modify(change: change)
            if let changeEndpoint = codeStore.getEndpoint(method.definedIn, searchInCurrent: true) {
                changeEndpoint.specialImports.insert("import JavaScriptCore")
                changeEndpoint.methods.append(changeMethod)
            }
        } else {
            let codeStore = CodeStore.getInstance()
            guard case let .method(m) = change.object else {
                fatalError()
            }
            
            var methodToModify: WrappedMethod
            
            if m.operationId == self.shortName {
                methodToModify = codeStore.getMethod(method.operationId, searchInCurrent: false)!
                let changeEndpoint = codeStore.getEndpoint(m.definedIn, searchInCurrent: true)!
                changeEndpoint.specialImports.insert("import JavaScriptCore")
                changeEndpoint.methods.append(methodToModify)
            } else {
                methodToModify = self
            }
            
            let replacementMethod = codeStore.getMethod(m.operationId, searchInCurrent: true)!
            
            let paramsOutput = Array(replacementMethod.parameters.dropLast(2))
            let paramsInput = Array(methodToModify.parameters.dropLast(2))
            
            methodToModify.parameterConversion = { () in
                """
                struct InputParam : Codable {
                    \(paramsInput.map({ "var \($0.name) : \($0.typeName.actualName)" }).joined(separator: "\n"))
                }

                struct OutputParam : Codable {
                    \(paramsOutput.map({ "var \($0.name) : \($0.typeName.actualName)" }).joined(separator: "\n"))
                }

                let context = JSContext()!

                context.evaluateScript(\"""
                \(change.customConvert!)
                \""")

                let inputEncoded = try! JSONEncoder().encode(InputParam(\(paramsInput.map({ "\($0.name) : \($0.name)" }).joined(separator: ", "))))

                let outputTmp = context.objectForKeyedSubscript("conversion").call(withArguments: [inputEncoded])?.toString()

                let outputDecoded = try! JSONDecoder().decode(OutputParam.self, from: outputTmp!.data(using: .utf8)!)
                """
            }
            
            methodToModify.nameToCall = { () in
                replacementMethod.shortName
            }
            
            methodToModify.apiMethodString = { () in
                """
                \(methodToModify.signatureString) {
                \(methodToModify.parameterConversion()!)
                return \(replacementMethod.definedInTypeName!.actualName).\(methodToModify.nameToCall())(\(paramsOutput.map({ "\($0.name) : outputDecoded.\($0.name)" }).joined(separator: ", ")), authorization: authorization, contentType: contentType)
                \(methodToModify.apiMethodResultMap)
                }
                """
            }
            
            if replacementMethod.returnTypeName.actualName != methodToModify.returnTypeName.actualName {
                let returnTypeChangeData = """
                {
                    "object":{
                       "operation-id":"\(methodToModify.shortName)",
                       "defined-in":"\(ownRoute)"
                    },
                    "target":"ReturnValue",
                    "replacement-id":"_",
                    "type":"\(replacementMethod.returnTypeName.mappedPublisherSuccessType)",
                    "custom-revert":"\(change.customRevert!)",
                    "replaced": {
                       "name":"_",
                       "type":"\(methodToModify.returnTypeName.mappedPublisherSuccessType)"
                    }
                }
                """.data(using: .utf8)!
                let returnTypeChange = try! JSONDecoder().decode(ReplaceChange.self, from: returnTypeChangeData)
                methodToModify.modify(change: returnTypeChange)
                if codeStore.getMethod(methodToModify.shortName, searchInCurrent: true) == nil {
                    codeStore.getEndpoint(m.definedIn, searchInCurrent: true)!.methods.append(methodToModify)
                }
            }
        }
    }
    
    /// Creates a method parameter from a `Parameter`
    /// - Parameter param: parameter from migration guide
    /// - Returns: method parameter
    private func createMethodParameter(param: Parameter) -> WrappedMethodParameter {
        let type = WrappedTypeName(name: param.type, actualName: param.type, isOptional: !param.required, isArray: param.type.isArrayType, isVoid: false, isPrimitive: param.type.isPrimitiveType)
        return WrappedMethodParameter(name: param.id!, isOptional: !param.required, typeName: type, actualTypeName: type, defaultValue: param.defaultValue)
    }
    
    
    /// Creates the map string function when method was replaced
    /// - Parameter change: ReplaceChange affecting this method
    /// - Returns: function which creates the map string
    private func mapStringFunction(change: ReplaceChange) -> (String) -> String {
        !change.type!.isPrimitiveType ? { type in
        !type.isPrimitiveType ?
        (type.isArrayType ?
        """
        .map({ (result) -> \(type) in
            let context = JSContext()!
            let encoded = try! JSONEncoder().encode(result)
            context.evaluateScript(\"""\n\(change.customRevert!)\n\""")
            let encString = context.objectForKeyedSubscript("conversion").call(withArguments: [String(data: encoded, encoding: .utf8)!])?.toString()
            return (try! JSONDecoder().decode(\(type.replacingOccurrences(of: "[", with: "[_")).self, from: encString!.data(using: .utf8)!)).map({\(type.itemType)($0)!})
        })
        """ :
        """
        .map({ (result) -> \(type) in
            let context = JSContext()!
            let encoded = try! JSONEncoder().encode(result)
            context.evaluateScript(\"""\n\(change.customRevert!)\n\""")
            let encString = context.objectForKeyedSubscript("conversion").call(withArguments: [String(data: encoded, encoding: .utf8)!])?.toString()
            return \(type)(try! JSONDecoder().decode(_\(type).self, from: encString!.data(using: .utf8)!))!
        })
        """)
        :
        """
        .map({ (result) -> \(type) in
            let context = JSContext()!
            let encoded = try! JSONEncoder().encode(result)
            context.evaluateScript(\"""\n\(change.customRevert!)\n\""")
            let encString = context.objectForKeyedSubscript("conversion").call(withArguments: [String(data: encoded, encoding: .utf8)!])?.toString()
            \(type.isCollectionType
            ? "return \(type)(try! JSONDecoder().decode(\(type).self, from: encString!.data(using: .utf8)!))!"
            : "return \(type.upperFirst)(encString)!"
            )
        })
        """
        }
        : { type in
            !type.isPrimitiveType ?
            (type.isArrayType ?
            """
            .map({ (result) -> \(type) in
                let context = JSContext()!
                context.evaluateScript(\"""\n\(change.customRevert!)\n\""")
                let encString = context.objectForKeyedSubscript("conversion").call(withArguments: [String(result)])?.toString()
                return (try! JSONDecoder().decode(\(type.replacingOccurrences(of: "[", with: "[_")).self, from: encString!.data(using: .utf8)!)).map({\(type.itemType)($0)!})
            })
            """ :
            """
            .map({ (result) -> \(type) in
                let context = JSContext()!
                context.evaluateScript(\"""\n\(change.customRevert!)\n\""")
                let encString = context.objectForKeyedSubscript("conversion").call(withArguments: [String(result)])?.toString()
                return \(type)(try! JSONDecoder().decode(_\(type).self, from: encString!.data(using: .utf8)!))!
            })
            """)
            :
            """
            .map({ (result) -> \(type) in
                let context = JSContext()!
                context.evaluateScript(\"""\n\(change.customRevert!)\n\""")
                let encString = context.objectForKeyedSubscript("conversion").call(withArguments: [String(result)])?.toString()
                \(type.isCollectionType
                ? "return \(type)(try! JSONDecoder().decode(\(type).self, from: encString!.data(using: .utf8)!))!"
                : "return \(type.upperFirst)(encString)!"
                )
            })
            """
        }
    }
}
