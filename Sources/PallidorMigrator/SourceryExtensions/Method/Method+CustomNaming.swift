//
//  Method+CustomNaming.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation
import SourceryRuntime

extension WrappedMethod {
    /// Important for API methods -> need to change typename of `element` to persistent typename
    var persistentName: String {
        """
        \(shortName)(\(self.parameterString()))
        """
    }

    /// only operation id without parameters and round brackets
    var shortName: String {
        guard let endIndex = name.firstIndex(of: "(") else {
            fatalError("Only methods can be shortend in their name.")
        }
        return String(name[name.startIndex..<endIndex])
    }
}
