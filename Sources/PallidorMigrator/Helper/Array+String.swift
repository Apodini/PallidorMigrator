//
//  Array+String.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

extension Array where Element == String {
    /// Joins all Strings in Array but skips empty values
    /// - Parameter separator: separator String
    /// - Returns: Joined String
    public func skipEmptyJoined(separator: String = "") -> String {
        self.filter({ !$0.isEmpty }).joined(separator: separator)
    }
    
    /// Combines join and map function
    /// - Parameter separator: separator String
    /// - Returns: Joined String
    public func mapJoined(separator: String = "") -> String {
        self.map({ $0 }).joined(separator: separator)
    }
}

extension Array where Element == String? {
    /// Joins all Strings in Array but skips empty & nil values
    /// - Parameter separator: separator String
    /// - Returns: Joined String
    public func skipEmptyJoined(separator: String = "") -> String {
        (self.filter({ $0 != nil && !$0!.isEmpty }) as! [String]).joined(separator: separator)
    }
}
