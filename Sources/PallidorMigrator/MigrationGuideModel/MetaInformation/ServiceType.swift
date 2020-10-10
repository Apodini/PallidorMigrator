//
//  ServiceType.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

/// service type stated in migration guide - currently REST only
enum ServiceType : String, CaseIterable, Decodable {
    case rest = "REST"
}
