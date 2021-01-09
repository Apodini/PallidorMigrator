//
//  ModelFacade.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation
import SourceryFramework
import PathKit

/// Used to write modified model templates to swift files
struct ModelFacade: Facade {
    var modifiables: [Modifiable]
    var targetDirectory: Path
    var migrationSet: MigrationSet?

    /// Persists models to files
    /// - Throws: error if writing fails
    /// - Returns: `[URL]` of file URLs
    func persist() throws -> [URL] {
        try self.modifiables.map { target -> URL in
            let template = ModelTemplate()
            guard let migrationSet = self.migrationSet else {
                fatalError("MigrationSet not initialized!")
            }
            guard let model = try migrationSet.activate(for: target) as? WrappedClass else {
                fatalError("Could not migrate model.")
            }
            guard let result = try? template.write(
                    model,
                    to: targetDirectory.persistentPath + Path("\(model.localName).swift")
            ) else {
                fatalError("Model could not be written to file.")
            }
            
            return result
        }
    }
}
