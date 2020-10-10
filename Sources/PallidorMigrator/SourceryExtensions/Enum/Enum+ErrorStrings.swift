//
//  Enum+ErrorStrings.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation
import SourceryRuntime

extension WrappedEnum {

    /// body of error enum
    var errorEnum : String {
        """
        \(cases.map({$0.errorCase()}).joined(separator: "\n"))
                
        init?(_ from: _\(localName)?) {
            if let from = from {
                switch from {
                    \(cases.map({$0.errorFrom()}).skipEmptyJoined(separator: "\n"))
                }
            } else {
                return nil
            }
        }
        
        """
    }
}

extension WrappedEnumCase {
     
    /// returns the code type of an error enum case
    var codeType : String {
        associatedValues[0].typeName.name.lowerFirst // currently always `int`
    }
    
    /// returns the error type of an error enum case
    var errorTypeFrom : String {
        associatedValues[1].typeName.name.isPrimitiveType ? associatedValues[1].typeName.name.lowerFirst : "\(associatedValues[1].typeName.name)(\(associatedValues[1].typeName.name.lowerFirst))!"
    }
    
}
