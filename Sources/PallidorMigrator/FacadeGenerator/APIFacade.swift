//
//  APIFacade.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation
import SourceryFramework
import PathKit

/// Used to write modified endpoint templates to swift files
struct APIFacade: Facade {
    var modifiables: [Modifiable]
    var targetDirectory: Path
    var migrationSet: MigrationSet?

    /// Persists endpoints to files
    /// - Throws: error if writing fails
    /// - Returns: `[URL]` of file URLs
    func persist() throws -> [URL] {
        let activated = try self.modifiables.map { mod -> WrappedStruct in
            guard let modifiable = try migrationSet!.activate(for: mod) as? WrappedStruct else {
                fatalError("APIFacade requires structs to be generated.")
            }
            return modifiable
        }
        return try activated.map { try APITemplate().write($0, to: targetDirectory.persistentPath + Path("\($0 .localName.removePrefix).swift"))! }
    }
}
