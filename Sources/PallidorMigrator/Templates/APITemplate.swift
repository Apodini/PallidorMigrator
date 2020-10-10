//
//  APITemplate.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation
import PathKit

/// Template which represents the code structure for an endpoint
struct APITemplate : CodeTemplate {
    
    func render(_ modifiable: Modifiable) -> String {
        let s = modifiable as! WrappedStruct
        
        return
            """
            import Foundation
            import Combine
            \(s.specialImports.mapJoined("\n"))
            \(s.annotation?.description ?? "")
            public struct \(s.localName) {
                \(s.variables.map({ $0.declaration() }).joined(separator: "\n"))
            
                \(s.methods.map({$0.apiMethodString()}).joined(separator: "\n\n"))
            
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
