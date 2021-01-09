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
            guard let migrationSet = self.migrationSet else {
                fatalError("MigrationSet not initialized!")
            }
            guard let modifiable = try migrationSet.activate(for: mod) as? WrappedStruct else {
                fatalError("APIFacade requires structs to be generated.")
            }
            return modifiable
        }
        
        
        return activated.map { file in
            let target = targetDirectory
                    .persistentPath + Path("\(file.localName.removePrefix).swift")
            
            guard let result = try? APITemplate().write(file, to: target) else {
                fatalError("Could not write file to target directory.")
            }

            return result
        }
    }
}
