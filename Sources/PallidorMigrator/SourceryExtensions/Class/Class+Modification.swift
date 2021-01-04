//
//  Class+Modification.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

extension WrappedClass {
    /// handle added a model
    /// - Parameter addChange: AddChange affecting this model
    internal func handleAddedProperty(_ addChange: AddChange) {
        // get all attribute names to filter them
        let addedIds = addChange.added.map { $0.id }

        _ = self.variables.filter { variable -> Bool in
            if addedIds.contains(variable.name) {
                variable.modify(change: addChange)
                return false
            }
            return true
        }
    }

    /// handle deleting a property
    /// - Parameter delChange: DeleteChange affecting a property of this model
    internal func handleDeletedProperty(_ delChange: DeleteChange) {
        guard let deletedProperty = delChange.fallbackValue as? Property else {
            fatalError("Fallback value for deleted property is malformed.")
        }

        let property = WrappedVariable(
            name: deletedProperty.id!,
            defaultValue: deletedProperty.defaultValue!,
            isMutable: true,
            isEnum: false,
            isCustomType: false,
            isArray: false,
            isCustomInternalEnumType: false,
            isOptional: true,
            isStatic: false,
            typeName: WrappedTypeName(
                name: deletedProperty.type,
                actualName: deletedProperty.type,
                isOptional: true,
                isArray: false,
                isVoid: false,
                isPrimitive: deletedProperty.type.isPrimitiveType)
        )

        property.modify(change: delChange)

        self.variables.append(property)
    }

    /// handle deleting a model
    /// - Parameter delChange: DeleteChange affecting this model
    internal func handleDeletedChange(_ delChange: DeleteChange) {
        self.annotation = .unavailable(msg: "This model is unavailable by API version: xxx")
        self.facadeFrom = { () in "" }
        self.facadeTo = { () in "" }
    }

    /// handle deleting an ofType model
    /// - Parameter delChange: DeleteChange affecting this model
    internal func handleDeletedOfType(_ delChange: DeleteChange) {
        guard let enums = nestedEnums else {
            return
        }

        for targetEnum in enums {
            targetEnum.modify(change: delChange)
        }
    }

    /// handle replacing a property
    /// - Parameter replaceChange: ReplaceChange affecting a property of this model
    internal func handleReplacedProperty(_ replaceChange: ReplaceChange) {
        specialImports.insert("import JavaScriptCore")

        let replacement = self.variables.first(where: { $0.id == replaceChange.replacementId })

        replacement!.modify(change: replaceChange)
    }

    /// handle renaming a property
    /// - Parameter renameChange: RenameChange affecting a property of this model
    internal func handleRenameProperty(_ renameChange: RenameChange) {
        let renamed = self.variables.first(where: { $0.id == renameChange.renamed!.id })

        renamed!.modify(change: renameChange)
    }

    /// handle renaming a model
    /// - Parameter renameChange: RenameChange affecting this model
    internal func handleRenameChange(_ renameChange: RenameChange) {
        let newName = self.localName
        self.localName = renameChange.originalId

        facadeFrom = { () in
            """
            init?(_ from : _\(newName)?) {
                if let from = from {
            \(self.replacedProperty ?
                """
                let context = JSContext()!
                \(self.variables.map { $0.replaceAdaption(true) }.skipEmptyJoined(separator: ", "))
                """
            : "")
                \(self.variables.map { $0.convertFrom() }.joined(separator: "\n"))
                } else {
                return nil
                }
            }
            """
        }

      facadeTo = { () in
            """
            func to() -> _\(newName)? {
            \(self.replacedProperty ?
            """
            let context = JSContext()!
            \(self.variables.map { $0.replaceAdaption(false) }.skipEmptyJoined(separator: ", "))
            """
            : "")
            return _\(newName)(\(self.variables
                                    .sorted(by: { $0.name < $1.name })
                                    .map { $0.convertTo() }
                                    .skipEmptyJoined(separator: ", ")))
            }
            """
        }
    }

    /// handle replacing a model
    /// - Parameter replaceChange: ReplaceChange affecting this model
    internal func handleReplacedChange(_ replaceChange: ReplaceChange) {
        specialImports.insert("import JavaScriptCore")

        let replacement = replaceChange.replacementId

        if let enums = nestedEnums {
            for targetEnum in enums {
                targetEnum.modify(change: replaceChange)
            }
        }

        for property in self.variables {
            property.modify(change: replaceChange)
        }

        self.facadeFrom = { () in
            """
            init?(_ from : _\(replacement)?) {
                if let from = from {
                let context = JSContext()!
                let fromEncoded = try! JSONEncoder().encode(from)
                context.evaluateScript(\"""
                \(replaceChange.customRevert!)
                \""")
                let encodedResult = context
                        .objectForKeyedSubscript("conversion")
                        .call(withArguments: [String(data: fromEncoded, encoding: .utf8)!])?.toString()
                let from = try! JSONDecoder().decode(\(self.localName).self, from: encodedResult!.data(using: .utf8)!)
                \(self.variables.map { $0.replaceAdaption(true) }.skipEmptyJoined(separator: "\n"))
                } else {
                return nil
                }
            }
            """
        }

        self.facadeTo = { () in
            """
            func to() -> _\(replacement)? {
            let context = JSContext()!
            let selfEncoded = try! JSONEncoder().encode(self)
            context.evaluateScript(\"""
            \(replaceChange.customConvert!)
            \""")
            let encodedResult = context
                    .objectForKeyedSubscript("conversion")
                    .call(withArguments: [String(data: selfEncoded, encoding: .utf8)!])?.toString()
            return try! JSONDecoder().decode(_\(replacement).self, from: encodedResult!.data(using: .utf8)!)
            }
            """
        }
    }
}
