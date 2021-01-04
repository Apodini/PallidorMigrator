//
//  ObjectType.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

/// object affected by change
enum ObjectType {
    case endpoint(Endpoint)
    case model(Model)
    case method(Method)
    case `enum`(EnumModel)
}
