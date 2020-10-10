//
//  AddMigration.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

/// Migration of an AddChange on a Modifiable
final class AddMigration: Migration {
    internal init(solvable: Bool, executeOn: Modifiable, change: AddChange) {
        super.init(solvable: solvable, executeOn: executeOn, change: change)
    }
}
