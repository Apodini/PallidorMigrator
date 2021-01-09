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
            public enum \(self.localName) : \(self.inheritedTypes.joined(separator: ", ")) {
                \(self.casesString)
            }
            """
        }
    }

    /// handle replacing an enum
    /// - Parameter change: ReplaceChange affecting this enum
    internal func handleReplacedChange(change: ReplaceChange) {
        guard let replaceChange = change.replaced as? EnumModel else {
            fatalError("Change is malformed: ReplaceChange")
        }
        let replaceEnumType = replaceChange.type ?? "String"

        self.specialImports.insert("import JavaScriptCore")

        self.externalEnum = {
            """
            \(self.casesString)

            func to() -> _\(change.replacementId)? {
                let context = JSContext()!
                context.evaluateScript(\"""
                \(
                    // must provide convert method due to migration guide constraints
                    // swiftlint:disable:next force_unwrapping
                    change.customConvert!)
                \""")
                let toTmp = context
                    .objectForKeyedSubscript("conversion")
                    .call(withArguments: [self.rawValue])?.toString()
                return _\(change.replacementId)(rawValue: \(replaceEnumType == "String" ? "toTmp!" : "Int(toTmp!)!" ))
            }

            init?(_ from: _\(change.replacementId)?) {
                if let from = from {
                    let context = JSContext()!
                    context.evaluateScript(\"""
                    \(
                        // must provide revert method due to migration guide constraints
                        // swiftlint:disable:next force_unwrapping
                        change.customRevert!)
                    \""")
                    let fromTmp = context
                        .objectForKeyedSubscript("conversion")
                        .call(withArguments: [from.rawValue])?.toString()
                    self.init(rawValue: \(
                        self.inheritedTypes[0] == "String" ? "fromTmp!" : "Int(fromTmp!)!"
                    ))
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
            // must provide fallback value due to migration guide constraints
            if let targetCase =
                self.cases
                .first(where: { (self.isOfType && $0.name ==
                                    change.fallbackValue!.id!.lowerFirst) // swiftlint:disable:this force_unwrapping
                                                || $0.name == change.fallbackValue!.id // swiftlint:disable:this force_unwrapping
            }) {
                targetCase.modify(change: change)
            }
        case .signature:
            self.annotation = .unavailable(msg: "Enum was removed in API version xxx")
            self.defaultInternal = {
                """
                \(
                    // is always set at this point
                    // swiftlint:disable:next force_unwrapping
                    self.annotation!)
                public enum \(self.localName) : \(self.inheritedTypes.joined(separator: ", ")) { }
                """
            }
            self.externalEnum = { () in "\(self.casesString)" }
        default:
            fatalError("Enum: change type not implemented")
        }
    }
}
