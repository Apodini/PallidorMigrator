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
        try self.modifiables.map { m -> URL in
            let template = ModelTemplate()
            let model = try migrationSet!.activate(for: m) as! WrappedClass
            return try template.write(model, to: targetDirectory.persistentPath + Path("\(model.localName).swift"))!
        }
    }
}
