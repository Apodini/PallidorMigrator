//
//  Annotation.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

/// Annotation which can be added to any `Modifiable`
enum Annotation: CustomStringConvertible {
    /// representation of annotation in template
    var description: String {
        get {
            switch self {
            case .deprecated(msg: let msg):
                return "@available(*, deprecated, message: \"\(msg)\")"
            case .unavailable(msg: let msg):
                return "@available(*, unavailable, message: \"\(msg)\")"
            }
        }
    }
    
    /// if modifiable is still available but should not be used anymore
    case deprecated(msg: String)
    /// if modifiable was removed
    case unavailable(msg: String)
}
