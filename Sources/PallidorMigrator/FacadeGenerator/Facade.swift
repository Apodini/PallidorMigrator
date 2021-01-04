//
//  Facade.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation
import PathKit

/// Protocol for facade template persisting
protocol Facade {
    var migrationSet: MigrationSet? { get set }
    var modifiables: [Modifiable] { get set }
    var targetDirectory: Path { get set }

    /// Persists modifiables to files
    /// - Throws: error if writing fails
    /// - Returns: `[URL]` of file URLs
    func persist() throws -> [URL]
}
