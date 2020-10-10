//
//  ModelTemplate.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation
import SourceryFramework
import SourceryRuntime
import PathKit

/// Template which represents the code structure for a model
struct ModelTemplate : CodeTemplate {
    
    func render(_ modifiable: Modifiable) -> String {
        let c = modifiable as! WrappedClass
        let enums = c.nestedEnums ?? [WrappedEnum]()
        TypeStore.nonPersistentTypes["_\(c.localName)"] = "\(c.localName)"
        
        return """
        import Foundation
        \(c.specialImports.mapJoined("\n"))
        \(c.annotation?.description ?? "")
        public class \(c.localName)\(c.isGeneric ? c.genericAnnotation : "") \(!c.inheritedTypes.isEmpty ? " : \(c.inheritedTypes.skipEmptyJoined(separator: ", "))" : "") {
        \(c.variables.map({ $0.declaration() }).joined(separator: "\n"))
        
        \(enums.filter({!$0.ignore}).map({$0.internalEnum}).joined(separator: "\n"))
        
        \(c.initializer())
        
        \(c.facadeFrom())
        
        \(c.facadeTo())
        
        }
        """
    }
    
    public func write(_ modifiable: Modifiable, to path: Path) throws -> URL? {
        let content = render(modifiable)
        
        guard !content.isEmpty else {
            return nil
        }
        
        let outputPath = URL(fileURLWithPath: path.string)
        try content.write(to: outputPath, atomically: true, encoding: .utf8)
        return outputPath
    }
    
}

