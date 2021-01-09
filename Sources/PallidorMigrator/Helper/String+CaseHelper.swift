//
//  String+CaseHelper.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

extension String {
    /// returns the value but uppercases the first letter
    public var upperFirst: String {
        guard let first = self.first else {
            fatalError("Tried to uppercase empty string.")
        }
        return first.uppercased() + self.dropFirst()
    }

    /// returns the value but lowercases the first letter
    public var lowerFirst: String {
        guard let first = self.first else {
            fatalError("Tried to lowercase empty string.")
        }
        return first.lowercased() + self.dropFirst()
    }

    /// removes a leading `_` from the string if one exists
    public var removePrefix: String {
        guard let first = self.first else {
            fatalError("Tried to remove prefix from empty string.")
        }
        return first == "_" ? String(self.dropFirst()) : self
    }

    /// adds a leading `_` from the string if none exists
    public var addPrefix: String {
        guard let first = self.first else {
            fatalError("Tried to add prefix to empty string.")
        }
        return first != "_" ? "_\(self)" : self
    }
}
