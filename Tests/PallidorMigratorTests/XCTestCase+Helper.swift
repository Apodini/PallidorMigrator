import XCTest
import Foundation
import SourceryFramework
@testable import PallidorMigrator

extension XCTestCase {
    var noChange: String { """
   {
       "summary" : "Here would be a nice summary what changed between versions",
       "api-spec": "OpenAPI",
       "api-type": "REST",
       "from-version" : "0.0.1b",
       "to-version" : "0.0.2",
       "changes" : [
       ]
   }
   """ }
    
    func getMigrationResult(migration: String, target: String) -> Modifiable {
        guard let sut = try? PallidorMigrator(
                targetDirectory: "",
                migrationGuidePath: nil,
                migrationGuideContent: migration) else {
            fatalError("Failed to initialize SUT.")
        }
       
        // swiftlint:disable:next force_try
        let fileParser = try! FileParser(contents: target)
        // swiftlint:disable:next force_try
        let code = try! fileParser.parse()
        guard let types = WrappedTypes(types: code.types).getModifiable() else {
            fatalError("Could not retrieve types.")
        }
        
        guard let result = try? sut.migrationSet.activate(for: types) else {
            fatalError("Migration failed.")
        }
        
        return result
    }
    
    func readResource(_ resource: String) -> String {
        guard let fileURL = Bundle.module.url(forResource: resource, withExtension: "md") else {
            XCTFail("Could not locate the resource")
            return ""
        }
        
        do {
            return String((try String(contentsOf: fileURL, encoding: .utf8)).dropLast())
        } catch {
            XCTFail("Could not read the resource")
        }
        
        return ""
    }
}
