//
//  SupportedLanguage.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

/// represents the supported language, currently only `Swift`
enum SupportedLanguage : String, CaseIterable, Decodable {
    case swift = "Swift"
}
