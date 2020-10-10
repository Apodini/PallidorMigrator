//
//  Enum+StringBuilder.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation
import SourceryRuntime

extension WrappedEnum {
    
    /// Declaration string for enum cases
    var casesString : String {
        isOfType ? self.cases.map({$0.ofCase}).joined(separator: "\n") : self.cases.map({$0.defaultCase()}).skipEmptyJoined(separator: "\n")
    }
    
    /// Representation of an internal enum
    var internalEnum : String {
       !isOfType ? defaultInternal()
        : ofInternal
    }
}

extension WrappedEnumCase {
       
    /// Declaration string for ofType enum case
    var ofCase : String {
        "\(self.annotationString ?? "")case \(name)\(hasAssociatedValue ? "(\(associatedValues.map({$0.typeName.name}).joined(separator: ", ")))" : "")"
    }
    
}

