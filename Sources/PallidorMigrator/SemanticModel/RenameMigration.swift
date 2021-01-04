//
//  RenameMigration.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

/// Migration of a RenameChange on a Modifiable
final class RenameMigration: Migration {
    internal init(solvable: Bool, executeOn: Modifiable, change: RenameChange) {
        super.init(solvable: solvable, executeOn: executeOn, change: change)
    }
    convenience init(solvable: Bool, executeOn: Modifiable, change: Changing) {
        guard let change = change as? RenameChange else {
            fatalError("Change malformed: RenameChange")
        }
        self.init(solvable: solvable, executeOn: executeOn, change: change)
    }
}
