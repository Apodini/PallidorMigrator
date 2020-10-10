//
//  CodeStore.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation
import SourceryFramework
import PathKit

/// Location of storing the parsed source code (API & previous Facade)
public class CodeStore {
    private static var instance: CodeStore?
    
    /// parsed source code located in facade folders
    var previousFacade: [Modifiable]?
    /// parsed source code located in API folders
    var currentAPI: [Modifiable] = [Modifiable]()
    
    /// true after initial setup
    var hasFacade: Bool {
        previousFacade != nil && previousFacade!.isEmpty
    }
    
    private init(previousFacade: [Modifiable], currentAPI: [Modifiable]) {
        self.previousFacade = previousFacade
        self.currentAPI = currentAPI
    }
    
    private init(targetDirectory: Path) {
        self.currentAPI = getCode(modelPath: targetDirectory + Path("Models"), apiPath: targetDirectory + Path("APIs"))!
        self.previousFacade = getCode(modelPath: targetDirectory + Path("PersistentModels"), apiPath: targetDirectory + Path("PersistentAPIs"))
    }
    
    /// required for UnitTests to reset the code store after each test
    static func clear() {
        CodeStore.instance = nil
    }
    
    /// Reads and parses the source code inside of target directories
    /// - Parameters:
    ///   - modelPath: path to models
    ///   - apiPath: path to endpoints
    /// - Returns: List of parsed source code items
    private func getCode(modelPath: Path, apiPath: Path) -> [Modifiable]? {
        let modelDirectory = modelPath
        let apiDirectory = apiPath
        
        let modelPaths = try? FileManager.default.swiftFilesInDirectory(atPath: modelDirectory.string + "/").sorted(by: { $0 == "_APIAliases.swift" || $0 == "APIAliases.swift" || $0 < $1 })
        let apiPaths = try? FileManager.default.swiftFilesInDirectory(atPath: apiDirectory.string + "/")
        let errorPaths = [modelPath.parent() + Path("_APIErrors.swift"), modelPath.parent() + Path("APIErrors.swift")]
    
        guard let mPaths = modelPaths, !mPaths.isEmpty else {
            return nil
        }
        
        var modifiables = [Modifiable]()
        
        for m in mPaths {
            let path = modelDirectory + Path(m)
            let content = try! path.read(.utf8)
            let fp = try! FileParser(contents: content, path: path)
            let code = try! fp.parse()
            let types = WrappedTypes(types: code.types)
            modifiables.append(types.getModifiable()!)
        }
        
        for a in apiPaths! {
            let path = apiDirectory + Path(a)
            let content = try! path.read(.utf8)
            let fp = try! FileParser(contents: content, path: path)
            let code = try! fp.parse()
            let types = WrappedTypes(types: code.types)
            modifiables.append(types.getModifiable()!)
        }
        
        for p in errorPaths {
            if let content = try? p.read(.utf8) {
                let fp = try! FileParser(contents: content, path: p)
                let code = try! fp.parse()
                let types = WrappedTypes(types: code.types)
                modifiables.append(types.getModifiable()!)
            }
        }
        
        return modifiables
    }
    
    
    /// Initializer for test cases
    /// - Parameters:
    ///   - previous: parsed source code items  of previous facade
    ///   - current: parsed source code items of current API
    static func initInstance(previous: [Modifiable], current: [Modifiable]) {
        if CodeStore.instance == nil {
            CodeStore.instance = CodeStore(previousFacade: previous, currentAPI: current)
        }
    }
    
    
    /// Initializer for executable
    /// - Parameter targetDirectory: path to source code files
    /// - Returns: initialized CodeStore
    static func initInstance(targetDirectory: Path) -> CodeStore {
        if CodeStore.instance == nil {
            CodeStore.instance = CodeStore(targetDirectory: targetDirectory)
        }
        return CodeStore.instance!
    }
    
    
    /// Singleton getter
    /// - Returns: returns singleton instance of CodeStore
    static func getInstance() -> CodeStore {
        guard CodeStore.instance != nil else {
            fatalError("Code store was not properly initialized.")
        }
        return CodeStore.instance!
    }
}
