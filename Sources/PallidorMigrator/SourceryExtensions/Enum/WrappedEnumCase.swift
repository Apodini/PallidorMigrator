//
//  WrappedEnumCase.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation
import SourceryRuntime

/// Wraps the EnumCase of Sourcery
class WrappedEnumCase: Modifiable {
    internal init(name: String, rawValue: String? = nil, hasAssociatedValue: Bool, associatedValues: [WrappedAssociatedValue]) {
        self.name = name
        self.rawValue = rawValue
        self.hasAssociatedValue = hasAssociatedValue
        self.associatedValues = associatedValues
    }
    
    convenience init(from: EnumCase) {
        self.init(name: from.name.removePrefix, rawValue: from.rawValue, hasAssociatedValue: from.hasAssociatedValue, associatedValues: from.associatedValues.map({ WrappedAssociatedValue(from: $0) }))
    }
    
    /// name of case
    var name: String
    /// raw value of case
    var rawValue: String?
    /// true if case has an associated value
    var hasAssociatedValue: Bool
    /// list of associated values
    var associatedValues: [WrappedAssociatedValue]
    
    /// string representation of annotation (varies for external/internal enum types)
    var annotationString: String?
    
    var id: String { self.name }
    
    var modified: Bool = false
    
    var annotation: Annotation?
    
    func modify(change: Change) {
        self.modified = true
        switch change.changeType {
        case .delete:
            self.annotation = .unavailable(msg: "This case is unavailable by API version: xxx")
            self.annotationString = "\(self.annotation!)\n"
            self.errorFrom = { () in "" }
            self.ofEncoding = { () in "" }
            self.ofDecoding = { _ in "" }
            self.ofTo = { _ in "" }
            self.ofFrom = { () in "" }
        default:
            fatalError("EnumCase: Change not implemented")
        }
    }
    
    /// `from()` string for error enum
    lazy var errorFrom : () -> String = {
        """
          case .\(self.name)(\(self.associatedValues.map({ "let \($0.typeName.name.lowerFirst)" }).joined(separator: ", "))):
            \(self.associatedValues.count > 1 ? "self = .\(self.name)(\(self.codeType), \(self.errorTypeFrom))" : "self = .\(self.name)(\(self.codeType))")
          """
    }
    
    /// declaration string for error enum
    lazy var errorCase : () -> String = {
        "\(self.annotationString ?? "")case \(self.name)(\(self.associatedValues.map({ TypeStore.nonPersistentTypes[$0.typeName.name] ?? $0.typeName.name }).joined(separator: ", ")))"
    }
    
    /// declaration string for default enums
    lazy var defaultCase : () -> String = {
        "\(self.annotationString ?? "")case \(self.name)\(self.hasAssociatedValue ? "(\(self.associatedValues.map({ $0.typeName.name }).joined(separator: ", ")))" : "")\((self.rawValue != nil) ? " = \"\(self.rawValue!)\"": "")"
    }
    
    /// `to()` string for an `OfType` internal enum
    lazy var ofTo : (_ definedIn: String) -> String = { (_ definedIn: String) in
        """
        case .\(self.name)(let ofType):
        return \(definedIn).\(self.name)(ofType.to()!)
        """
    }
    
    /// `from()` string for an `OfType` internal enum
    lazy var ofFrom : () -> String = { () in
        """
        case .\(self.name)(let fromType):
        self = .\(self.name)(\(self.associatedValues[0].typeName.name)(fromType)!)
        break
        """
    }
    
    /// decoding string for an `OfType` internal enum
    lazy var ofDecoding : (_ definedIn: String) -> String = { (_ definedIn: String) in
        """
        if let \(self.name) = try? \(self.name.upperFirst).init(from: decoder) {
            self = .\(self.name)(\(self.name))
            return
        }
        """
    }
    
    /// encoding string for an `OfType` internal enum
    lazy var ofEncoding : () -> String = {
        """
        case .\(self.name)(let of):
            try of.encode(to: encoder)
            break
        """
    }
}
