//
//  TargetType.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

/// represents the target of a change as stated in migration guide
public enum TargetType: String, CaseIterable, Decodable {
    case property = "Property"
    case signature = "Signature"
    case parameter = "Parameter"
    case contentBody = "Content-Body"
    case returnValue = "ReturnValue"
    case `case` = "Case"
}
