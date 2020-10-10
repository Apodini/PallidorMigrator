//
//  Enum+OfTypes.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation
import SourceryRuntime

extension WrappedEnum {
            
    /// En-/Decoding for ofType internal enums
    var ofTypeCoding : String {
        """
        public func encode(to encoder: Encoder) throws {
                   switch self {
                        \(self.cases.map({$0.ofEncoding()}).joined(separator: "\n"))
                   }
        }
        
        public init(from decoder: Decoder) throws {
            
            \(self.cases.map({$0.ofDecoding(self.localName)}).joined(separator: "\n"))
            
            throw APIEncodingError.canNotEncodeOfType(\(self.localName).self)
        }
        """
    }
    
    /// Default representation of ofType internal enums
    var ofInternal : String {
        """
        //sourcery: OfTypeEnum
        public enum \(localName) : \(inheritedTypes.mapJoined(separator: ", ")) {
            \(casesString)
        
            \(isOfType ? ofTypeCoding : "")
        
            func to() -> \(name.addPrefix) {
                switch self {
                    \(cases.map({$0.ofTo(name.addPrefix)}).joined(separator: "\n"))
                }
            }
            
            init?(_ from: \(name.addPrefix)?) {
                if let from = from {
                    switch from {
                                \(cases.map({$0.ofFrom()}).joined(separator: "\n"))
                            }
                } else {
                    return nil
                }
            }
        
        }
        """
    }
}

