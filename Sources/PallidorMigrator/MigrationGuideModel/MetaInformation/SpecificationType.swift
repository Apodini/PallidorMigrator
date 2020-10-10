//
//  SepcificationType.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

/// represents specification type as stated in migration guide, currently only `OpenAPI` supported
enum SpecificationType : String, CaseIterable, Decodable {
    case openapi = "OpenAPI"
}
