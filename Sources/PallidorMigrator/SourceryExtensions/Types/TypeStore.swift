//
//  TypeStore.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation
import SourceryRuntime

/// Temporary storage of non persistent type names.
enum TypeStore {
    static var nonPersistentTypes = [String: String]()
}
