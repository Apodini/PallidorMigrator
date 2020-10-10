//
//  Set+String.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

extension Set where Element == String {
    
    /// Joins all Strings in Set but skips empty values
    /// - Parameter separator: separator String
    /// - Returns: Joined String
    public func mapJoined(_ separator: String = "") -> String {
        self.map({$0}).joined(separator: separator)
    }
}
