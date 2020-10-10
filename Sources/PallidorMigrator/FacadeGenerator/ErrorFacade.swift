//
//  ErrorFacade.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation
import PathKit
import SourceryFramework

/// Used to write modified error enum templates to swift files
struct ErrorFacade : Facade {
    
    var migrationSet: MigrationSet? = nil
    
    /// here the modifiables array contains only two values: _APIError & APIError
    var modifiables: [Modifiable]
    var targetDirectory : Path
    
    /// Persists error enums to files
    /// - Throws: error if writing fails
    /// - Returns: `[URL]` of file URLs
    func persist() throws -> [URL] {
        let template = ErrorEnumTemplate()
        let newErrorEnum = modifiables[0] as! WrappedEnum
       
        if modifiables.count == 2 {
            let facadeErrorEnum = modifiables[1] as! WrappedEnum
            for c in newErrorEnum.compareCases(facadeErrorEnum) {
                facadeErrorEnum.modify(change: c)
            }
            return [try template.write(facadeErrorEnum, to: targetDirectory + Path("APIErrors.swift"))!]
        }
        
        return [try template.write(newErrorEnum, to: targetDirectory + Path("APIErrors.swift"))!]
    }
}
