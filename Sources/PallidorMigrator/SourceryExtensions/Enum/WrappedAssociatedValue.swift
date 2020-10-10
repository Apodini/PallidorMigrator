//
//  WrappedAssociatedValue.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation
import SourceryRuntime

/// Wraps the AssociatedValue Sourcery Type
class WrappedAssociatedValue {
    
    internal init(localName: String? = nil, typeName: WrappedTypeName) {
        self.localName = localName
        self.typeName = typeName
    }
    
    convenience init(from: AssociatedValue) {
        self.init(localName: from.localName?.removePrefix, typeName: WrappedTypeName(from: from.typeName))
    }
    
    /// name of associated value
    var localName: String?
    /// type of associated value
    var typeName: WrappedTypeName
}
