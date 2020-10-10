//
//  EnumTemplate.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation
import SourceryFramework
import SourceryRuntime
import PathKit

/// Template which represents the code structure for an enum
struct EnumTemplate: CodeTemplate {
    func render(_ modifiable: Modifiable) -> String {
        let e = modifiable as! WrappedEnum
        TypeStore.nonPersistentTypes["_\(e.localName)"] = e.localName
        let annotation = e.annotation != nil ? "\n\(e.annotation!.description)" : ""
        let imports = e.specialImports.isEmpty ? "" : "\n\(e.specialImports.joined(separator: "\n"))"
        return """
        import Foundation\(imports)
        \(annotation)
        public enum \(e.localName): \(e.inheritedTypes.mapJoined(separator: ", ")) {
            \(e.externalEnum())
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
