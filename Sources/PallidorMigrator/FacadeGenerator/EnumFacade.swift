//
//  EnumFacade.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation
import PathKit

/// Used to write modified enum templates to swift files
struct EnumFacade: Facade {
    var modifiables: [Modifiable]
    var targetDirectory: Path
    var migrationSet: MigrationSet?

    /// Persists enums to files
    /// - Throws: error if writing fails
    /// - Returns: `[URL]` of file URLs
    func persist() throws -> [URL] {
        try self.modifiables.map { target -> URL in
            let template = EnumTemplate()
            guard let migratedEnum = try migrationSet!.activate(for: target) as? WrappedEnum else {
                fatalError("Could not migrate enum.")
            }
            return try template.write(migratedEnum, to: targetDirectory.persistentPath + Path("\(migratedEnum.localName).swift"))!
        }
    }
}
