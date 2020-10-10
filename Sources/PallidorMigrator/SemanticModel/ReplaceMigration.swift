//
//  ReplaceMigration.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

/// Migration of a ReplaceChange on a Modifiable
final class ReplaceMigration : Migration {
    
    internal init(solvable: Bool, executeOn: Modifiable, change: ReplaceChange) {
        super.init(solvable: solvable, executeOn: executeOn, change: change)
    }
        
}
