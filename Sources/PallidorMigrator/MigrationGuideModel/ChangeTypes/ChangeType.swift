//
//  ChangeType.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation


/// Type of change as stated in migration guide
enum ChangeType: String, CaseIterable {
    case add = "Add"
    case delete = "Delete"
    case rename = "Rename"
    case replace = "Replace"
    case `nil` = ""
}
