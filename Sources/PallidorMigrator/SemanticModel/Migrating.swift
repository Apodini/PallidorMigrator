//
//  Migrating.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

/// Migrating protocol needs to be implemented by all migration types
protocol Migrating {
    /// true if migration can be resolved by actions
    var solvable: Bool { get set }
    /// true if migration was already executed on modifiable
    var executed: Bool { get set }
    /// the change this migration action results from
    var change: Change { get set }
    /// modifiable which is about to be changed
    var executeOn: Modifiable { get set }

    /// execution of the migrating actions defined by change on the modifiable
    func execute() throws
}
