//
//  Variable+Modification.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

extension WrappedVariable {
    /// handle added a variable
    /// - Parameter addChange: AddChange affecting this variable
    internal func handleAddChange(_ addChange: AddChange) {
        guard let attribute = addChange.added.first(where: { $0.id == name })! as? Property else {
            fatalError("Property \(name) was not found.")
        }

        self.defaultValue = attribute.defaultValue

        self.initParam = { () in "\(self.name): \(self.typeName.name.wrapped) = nil" }

        self.initBody = { () in
            """
self.\(self.name) = \(self.name) ?? \(TypeConversion
                                        .getDefaultValueInit(
                                            type: self.typeName.actualName,
                                            defaultValue: self.defaultValue ?? "")
)
""" }
    }

    /// handle deletion of a property
    /// - Parameter delChange: DeleteChange affecting this variable
    internal func handleDeletedChange(_ delChange: DeleteChange) {
        self.convertTo = { () in "" }
        self.convertFrom = { () in
            if self.typeName.actualName.unwrapped.isCollectionType ||
                !self.typeName.actualName.unwrapped.isPrimitiveType {
                return """
self.\(self.name) = try JSONDecoder().decode(\(
    self.typeName.actualName.unwrapped
).self, from: \"\(
        self.defaultValue!
    )\".data(using: .utf8)!
"""
            } else if self.typeName.actualName.unwrapped.isString {
                return "self.\(self.name) = \"\(self.defaultValue!)\""
            } else {
                return "self.\(self.name) = \(self.defaultValue!)"
            }
        }
    }

    /// handle renaming of property
    /// - Parameter renameChange: RenameChange affecting this variable
    internal func handleRenameChange(_ renameChange: RenameChange) {
        let newName = self.name
        self.name = renameChange.originalId
        self.convertFrom = { () in
            self.unmodifiedFrom.replacingOccurrences(of: "from.\(self.name)", with: "from.\(newName)")
        }
        self.convertTo = { () in
            self.unmodifiedTo.replacingOccurrences(of: "\(self.name):", with: "\(newName):")
        }
    }

    fileprivate func getFromConversionString(
        _ replaceChange: ReplaceChange,
        _ replacedProperty: Property
    ) -> String {
       """
        context.evaluateScript(\"""\n\(replaceChange.customRevert!)\n\""")
        let \(replaceChange.replacementId)Encoded = \(TypeConversion
                                                        .getEncodingString(
                                                            id: "from.\(replaceChange.replacementId)",
                                                            type: replaceChange.type!,
                                                            required: replacedProperty.required)
        )
        let \(
            self
                .id)Tmp = context.objectForKeyedSubscript("conversion").call(withArguments: [\(
            replaceChange
                .replacementId
        )Encoded])?.toString()
        let \(self.id) = \(TypeConversion
                            .getDecodingString(
                                id: "\(self.id)Tmp",
                                type: self.typeName.actualName)
        )
    """
    }

    fileprivate func getToConversionString(
        _ replaceChange: ReplaceChange,
        _ replacedProperty: Property
    ) -> String {
       """
            context.evaluateScript(\"""\n\(replaceChange.customConvert!)\n\""")

            let \(self.id)Encoded = \(TypeConversion
                                        .getEncodingString(
                                            id: self.id,
                                            type: self.typeName.name,
                                            required: replacedProperty.required)
            )

            let \(replaceChange
                    .replacementId
            )Tmp = context.objectForKeyedSubscript("conversion").call(withArguments: [\(
                self.id)Encoded])?.toString()

            let \(replaceChange.replacementId) = \(TypeConversion
                                                    .getDecodingString(
                                                        id: "\(replaceChange.replacementId)Tmp",
                                                        type: replaceChange.type!)
            )
            """
    }

    fileprivate func setReplacementAdaption(_ replaceChange: ReplaceChange, _ replacedProperty: Property) {
        self.replaceAdaption = { isFromConversion in
            isFromConversion ?
                self.getFromConversionString(replaceChange, replacedProperty)
                : self.getToConversionString(replaceChange, replacedProperty)
        }
    }

    /// handle replacing of property
    /// - Parameter replaceChange: ReplaceChange affecting this variable
    internal func handleReplacedChange(_ replaceChange: ReplaceChange) {
        guard let replacedProperty = replaceChange.replaced as? Property else {
            fatalError("Replacement could not be cast to Property.")
        }

        self.name = replacedProperty.id!
        self.defaultValue = replacedProperty.defaultValue
        self.isCustomType = !replacedProperty.type.isPrimitiveType
        self.isArray = replacedProperty.type.unwrapped.isArrayType
        self.isOptional = !replacedProperty.required
        self.typeName = WrappedTypeName(
            name: replacedProperty.type,
            actualName: replacedProperty.type,
            isOptional: !replacedProperty.required,
            isArray: replacedProperty.type.unwrapped.isArrayType,
            isVoid: false,
            isPrimitive: replacedProperty.type.isPrimitiveType
        )

        setReplacementAdaption(replaceChange, replacedProperty)

        convertTo = { () in self.replacedTo(replaceChange.replacementId) }
        convertFrom = { () in self.replacedFrom(self.id) }
    }

    /// handle replacing of the parent model of a property
    /// - Parameter replaceChange: ReplaceChange affecting the parent model
    internal func handleReplacedParentChange(_ replaceChange: ReplaceChange) {
        self.replaceAdaption = { $0 ? "self.\(self.name) = from.\(self.name)" : "" }
    }
}
