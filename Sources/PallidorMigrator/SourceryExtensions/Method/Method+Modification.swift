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
            case .parameter:
                let renamedParam = self.parameters.first(where: { $0.name == change.renamed!.id })!
                renamedParam.modify(change: change)
            default:
                fatalError("Target not supported for RenameChange of method.")
            }
        case .endpoint(let endpoint):
            apiMethodString = { () in
                """
                \(self.signatureString) {
                \(self.parameterConversion() ?? "")
                return _\(Endpoint.endpointName(from: endpoint.id!)).\(
                    self.nameToCall())(\(self.parameters
                                            .map { $0.endpointCall() }
                                            .skipEmptyJoined(separator: ", ")))
                \(self.apiMethodResultMap)
                }
                """
            }
        default:
            fatalError("Target object malformed.")
        }
    }

    /// handle deleting a method
    /// - Parameter change: DeleteChange affecting this method
    func handleDeleteChange(change: DeleteChange) {
        switch change.target {
        case .parameter,
             .contentBody:
            guard let param = change.fallbackValue as? Parameter else {
                fatalError("Fallback value is malformed. Must be parameter.")
            }
            let deletedParam = createMethodParameter(param: param)
            if change.target == .contentBody {
                deletedParam.name = "element"
            }
            deletedParam.modify(change: change)
            let insertIndex = self.parameters
                .firstIndex(where: { $0.name > deletedParam.name
                                || $0.name == "element"
                                || $0.name == "authorization" })!
            self.parameters.insert(deletedParam, at: insertIndex)
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
        default:
            fatalError("Target not supported for DeleteChange of method.")
        }
    }

    /// handle adding a method parameter or content body
    /// - Parameter change: AddChange affecting this method
    func handleAddChange(change: AddChange) {
        switch change.target {
        case .parameter:
            for addition in change.added {
                guard let param = addition as? Parameter else {
                    fatalError("Added value is malformed. Must be parameter.")
                }
                self.parameters.first(where: { $0.id == param.id })!.modify(change: change)
            }
        case .contentBody:
            let body = self.parameters.first(where: { $0.name == "element" })
            body!.modify(change: change)
        default:
            fatalError("Target type not supported for adding to method.")
        }
    }

    /// handle replacing a method
    /// - Parameter change: ReplaceChange affecting this method
    func handleReplaceChange(change: ReplaceChange) {
        switch change.target {
        case .parameter:
            let replaceIndex = self.parameters.firstIndex(where: { $0.id == change.replacementId })
            guard let param = change.replaced! as? Parameter else {
                fatalError("Replaced value is malformed. Must be parameter.")
            }
            let original = createMethodParameter(param: param)
            original.modify(change: change)
            self.parameters[replaceIndex!] = original
            self.paramsRequireJSContext = true
        case .returnValue:
            guard let returnValue = change.replaced! as? ReturnValue else {
                fatalError("Replaced value is malformed. Must be return value.")
            }
            self.returnTypeName = WrappedTypeName(
                name: returnValue.type,
                actualName: returnValue.type,
                isOptional: false,
                isArray: returnValue.type.isArrayType,
                isVoid: false,
                isPrimitive: returnValue.type.isPrimitiveType
            )
            self.mapString = mapStringFunction(change: change)
        case .contentBody:
            let element = self.parameters.first(where: { $0.name == "element" })
            element!.modify(change: change)
            self.paramsRequireJSContext = true
        case .signature:
            replaceMethod(change: change)
        case .property:
            fatalError("Property can not be target of a method migration")
        case .case:
            fatalError("Case can not be target of a method migration")
        }
    }

    fileprivate func replaceMethodInOtherEndpoint(_ method: Method, _ change: ReplaceChange) {
        let codeStore = CodeStore.getInstance()
        let changeMethod = codeStore.getMethod(method.operationId)!
        changeMethod.modify(change: change)
        if let changeEndpoint = codeStore.getEndpoint(method.definedIn, searchInCurrent: true) {
            changeEndpoint.specialImports.insert("import JavaScriptCore")
            changeEndpoint.methods.append(changeMethod)
        }
    }

    fileprivate func replaceReturnValue(
        _ replacementMethod: WrappedMethod,
        _ methodToModify: WrappedMethod,
        _ ownRoute: String,
        _ change: ReplaceChange,
        _ targetMethod: (Method)
    ) {
        let codeStore = CodeStore.getInstance()
        if replacementMethod.returnTypeName.actualName
            .replacingOccurrences(of: "_", with: "") != methodToModify.returnTypeName.actualName {
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
            let returnTypeChange = try? JSONDecoder().decode(ReplaceChange.self, from: returnTypeChangeData)
            guard let rChange = returnTypeChange else {
                fatalError("Return type change is malformed.")
            }
            methodToModify.modify(change: rChange)
            if codeStore.getMethod(methodToModify.shortName, searchInCurrent: true) == nil {
                codeStore.getEndpoint(targetMethod.definedIn, searchInCurrent: true)!.methods.append(methodToModify)
            }
        }
    }

    fileprivate func replaceMethodInSameEndpoint(
        _ method: Method,
        _ change: ReplaceChange,
        _ ownRoute: String
    ) {
        let codeStore = CodeStore.getInstance()
        guard case let .method(targetMethod) = change.object else {
            fatalError("Only methods can be targeted for replacing methods.")
        }
        var methodToModify: WrappedMethod

        if targetMethod.operationId == self.shortName {
            methodToModify = codeStore.getMethod(method.operationId, searchInCurrent: false)!
            let changeEndpoint = codeStore.getEndpoint(targetMethod.definedIn, searchInCurrent: true)!
            changeEndpoint.specialImports.insert("import JavaScriptCore")
            changeEndpoint.methods.append(methodToModify)
        } else {
            methodToModify = self
        }

        let replacementMethod = codeStore.getMethod(targetMethod.operationId, searchInCurrent: true)!

        let paramsOutput = Array(replacementMethod.parameters.dropLast(2))
        let paramsInput = Array(methodToModify.parameters.dropLast(2))

        setParameterConversion(methodToModify, paramsInput, paramsOutput, change)

        methodToModify.nameToCall = { () in
            replacementMethod.shortName
        }

        setMethodString(methodToModify, replacementMethod, paramsOutput)

        replaceReturnValue(replacementMethod, methodToModify, ownRoute, change, targetMethod)
    }

    /// Replacing a method
    /// - Parameter change: ReplaceChange affecting this method
    private func replaceMethod(change: ReplaceChange) {
        guard let method = change.replaced as? Method else {
            fatalError("Replacement malformed. Must be of type method.")
        }
        let ownRoute = Endpoint.routeName(from: self.definedInTypeName!.actualName)

        if method.definedIn != ownRoute {
            replaceMethodInOtherEndpoint(method, change)
        } else {
            replaceMethodInSameEndpoint(method, change, ownRoute)
        }
    }

    fileprivate func setParameterConversion(
        _ methodToModify: WrappedMethod,
        _ paramsInput: [WrappedMethodParameter],
        _ paramsOutput: [WrappedMethodParameter],
        _ change: ReplaceChange
    ) {
        methodToModify.parameterConversion = { () in
            """
                struct InputParam : Codable {
                    \(paramsInput.map { "var \($0.name) : \($0.typeName.actualName)" }.joined(separator: "\n"))
                }

                struct OutputParam : Codable {
                    \(paramsOutput.map { "var \($0.name) : \($0.typeName.actualName)" }.joined(separator: "\n"))
                }

                let context = JSContext()!

                context.evaluateScript(\"""
                \(change.customConvert!)
                \""")

                let inputEncoded = try! JSONEncoder().encode(InputParam(\(paramsInput
                                                                            .map { "\($0.name) : \($0.name)" }
                                                                            .joined(separator: ", "))))

                let outputTmp = context
                            .objectForKeyedSubscript("conversion")
                            .call(withArguments: [inputEncoded])?.toString()

                let outputDecoded = try! JSONDecoder().decode(OutputParam.self, from: outputTmp!.data(using: .utf8)!)
                """
        }
    }

    fileprivate func setMethodString(
        _ methodToModify: WrappedMethod,
        _ replacementMethod: WrappedMethod,
        _ paramsOutput: [WrappedMethodParameter]
    ) {
        methodToModify.apiMethodString = { () in
            """
                \(methodToModify.signatureString) {
                \(methodToModify.parameterConversion()!)
                return \(replacementMethod
                            .definedInTypeName!.actualName).\(methodToModify
                                                                .nameToCall())(\(paramsOutput
                                                                                    .map {
                                                    "\($0.name) : outputDecoded.\($0.name)"
                                                                                    }
                .joined(separator: ", ")), authorization: authorization, contentType: contentType)
                \(methodToModify.apiMethodResultMap)
                }
                """
        }
    }

    /// Creates a method parameter from a `Parameter`
    /// - Parameter param: parameter from migration guide
    /// - Returns: method parameter
    private func createMethodParameter(param: Parameter) -> WrappedMethodParameter {
        let type = WrappedTypeName(
            name: param.type,
            actualName: param.type,
            isOptional: !param.required,
            isArray: param.type.isArrayType,
            isVoid: false,
            isPrimitive: param.type.isPrimitiveType
        )
        return WrappedMethodParameter(
            name: param.id!,
            isOptional: !param.required,
            typeName: type,
            actualTypeName: type,
            defaultValue: param.defaultValue
        )
    }

    /// Creates the map string function when method was replaced
    /// - Parameter change: ReplaceChange affecting this method
    /// - Returns: function which creates the map string
    private func mapStringFunction(change: ReplaceChange) -> (String) -> String {
        !change.type!.isPrimitiveType ? mapStringComplexTypes(change)
        : mapStringPrimitiveTypes(change)
    }
}
