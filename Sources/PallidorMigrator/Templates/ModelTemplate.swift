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
struct ModelTemplate: CodeTemplate {
    func render(_ modifiable: Modifiable) -> String {
        guard let facadeModel = modifiable as? WrappedClass else {
            fatalError("ModelTemplate requires classes.")
        }
        let enums = facadeModel.nestedEnums ?? [WrappedEnum]()
        TypeStore.nonPersistentTypes["_\(facadeModel.localName)"] = "\(facadeModel.localName)"

        return """
        import Foundation
        \(facadeModel.specialImports.joined(separator: "\n"))
        \(facadeModel.annotation?.description ?? "")
        public class \(facadeModel.localName)\(facadeModel.isGeneric ? facadeModel.genericAnnotation : "") \(!facadeModel.inheritedTypes.isEmpty ? " : \(facadeModel.inheritedTypes.skipEmptyJoined(separator: ", "))" : "") {
        \(facadeModel.variables.map { $0.declaration() }.joined(separator: "\n"))

        \(enums.filter { !$0.ignore }.map { $0.internalEnum }.joined(separator: "\n"))

        \(facadeModel.initializer())

        \(facadeModel.facadeFrom())

        \(facadeModel.facadeTo())

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
