//
//  ErrorEnumTemplate.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation
import SourceryFramework
import SourceryRuntime
import PathKit

/// Template which represents the code structure for the `OpenAPIError` enum
struct ErrorEnumTemplate: CodeTemplate {
    func render(_ modifiable: Modifiable) -> String {
        let e = modifiable as! WrappedEnum
        TypeStore.nonPersistentTypes["_\(e.localName)"] = e.localName
        return """
        import Foundation
        
        public enum \(e.localName): \(e.inheritedTypes.map({ $0 }).joined(separator: ", ")) {
            \(e.errorEnum)
        }
        """
    }
    
    func write(_ modifiable: Modifiable, to path: Path) throws -> URL? {
        let content = render(modifiable)
        
        guard !content.isEmpty else {
            return nil
        }
        
        let outputPath = URL(fileURLWithPath: path.string)
        try content.write(to: outputPath, atomically: true, encoding: .utf8)
        return outputPath
    }
}
