//
//  SemanticVersion.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

/// represents the semantic version of the migration guide
class SemanticVersion: Comparable {
    internal init(versionString: String) {
        let versions = versionString.split(separator: ".")
        guard let major = Int(versions[0]), let minor = Int(versions[1]) else {
            fatalError("Semantic version is malformed. Major/Minor must be integers.")
        }
        self.major = major
        self.minor = minor
        self.patch = String(versions[2])
    }

    static func < (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        if lhs.major > rhs.major {
            return false
        }

        if lhs.major == rhs.major && lhs.minor > rhs.minor {
            return false
        }

        if lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch >= rhs.patch {
            return false
        }

        return true
    }

    static func <= (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        lhs == rhs || lhs < rhs
    }

    static func == (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch == rhs.patch
    }

    /// MAJOR.x.x
    var major: Int
    /// x.MINOR.x
    var minor: Int
    /// x.x.PATCH
    var patch: String
}
