import XCTest
import Foundation
import SourceryFramework
@testable import PallidorMigrator

extension XCTestCase {
    var noChange: String { """
   {
       "lang" : "Swift",
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
        let sut = try! PallidorMigrator(targetDirectory: "", migrationGuidePath: nil, migrationGuideContent: migration)
        let fp = try! FileParser(contents: target)
        let code = try! fp.parse()
        let types = WrappedTypes(types: code.types)
        return try! sut.migrationSet.activate(for: types.getModifiable())
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
            print(error)
        }
        
        return ""
    }
}
