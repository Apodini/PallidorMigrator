//
//  Migrating.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

/// Abstract migration
class Migration: Migrating {
    internal init(solvable: Bool, executeOn: Modifiable, change: Change) {
        self.solvable = solvable
        self.change = change
        self.executeOn = executeOn
    }
    
    var solvable: Bool
    
    var change: Change
    
    var executeOn: Modifiable
    
    var executed: Bool = false
    
    func execute() throws {
        guard solvable else {
            throw RuleError.notSupported(msg: "Unsupported rule: \(executeOn.id) modified by \(change.changeType)")
        }
        if !executed {
            executeOn.modify(change: change)
            executed = true
        }
    }
    
    private enum RuleError: Error {
        case notSupported(msg: String)
    }
}
