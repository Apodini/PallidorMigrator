// Identifier_name linting rule is disabled
// because enum cases reflect the names of corresponding test files
// Force try is disabled for lines that refer to fetching and parsing
// source code with Sourcery.
// swiftlint:disable identifier_name
import XCTest
import SourceryFramework
@testable import PallidorMigrator

class EnumTests: XCTestCase {
    override func tearDown() {
        CodeStore.clear()
        super.tearDown()
    }
    
    func testNoChangeEnum() {
        let migrationResult = getMigrationResult(
            migration: noChange,
            target: readResource(Resources.EnumTimeMode.rawValue)
        )
        let result = EnumTemplate().render(migrationResult)

        XCTAssertEqual(result, readResource(Resources.ResultEnumTimeMode.rawValue))
    }
    
    let deleteEnumCaseChange = """
   {
       "summary" : "Here would be a nice summary what changed between versions",
       "api-spec": "OpenAPI",
       "api-type": "REST",
       "from-version" : "0.0.1b",
       "to-version" : "0.0.2",
       "changes" : [
           {
               "object" : {
                   "enum-name" : "TimeMode"
               },
               "target" : "Case",
               "fallback-value" : {
                    "case" : "UTC"
                }
           }
       ]

   }
   """
    
    func testDeletedCase() {
        // swiftlint:disable:next force_try
        let fp = try! FileParser(contents: readResource(Resources.EnumTimeModeFacade.rawValue))
        // swiftlint:disable:next force_try
        let code = try! fp.parse()
        let types = WrappedTypes(types: code.types)
        guard let facade = types.getModifiable() else {
            fatalError("Could not retrieve previous modifiable.")
        }
        
        CodeStore.initInstance(previous: [facade], current: [])
        
        let migrationResult = getMigrationResult(
            migration: deleteEnumCaseChange,
            target: readResource(Resources.EnumTimeModeDeletedCase.rawValue)
        )
        let result = EnumTemplate().render(migrationResult)

        XCTAssertEqual(result, readResource(Resources.ResultEnumTimeModeDeletedCase.rawValue))
    }
    
    let deleteEnumChange = """
   {
       "summary" : "Here would be a nice summary what changed between versions",
       "api-spec": "OpenAPI",
       "api-type": "REST",
       "from-version" : "0.0.1b",
       "to-version" : "0.0.2",
       "changes" : [
           {
               "object" : {
                   "enum-name" : "TimeMode"
               },
               "target" : "Signature",
               "fallback-value" : { }
           }
       ]

   }
   """
    
    func testDeleted() {
        // swiftlint:disable:next force_try
        let fp = try! FileParser(contents: readResource(Resources.EnumTimeModeFacade.rawValue))
        // swiftlint:disable:next force_try
        let code = try! fp.parse()
        let types = WrappedTypes(types: code.types)
        guard let facade = types.getModifiable() else {
            fatalError("Could not retrieve previous modifiable.")
        }
        
        CodeStore.initInstance(previous: [facade], current: [])
        
        // irrelevant result
        _ = getMigrationResult(
            migration: deleteEnumChange,
            target: readResource(Resources.EnumPlaceholder.rawValue)
        )

        guard let migrationResult = CodeStore
                .getInstance()
                .getEnum(facade.id, searchInCurrent: true) else {
            fatalError("Migration failed.")
        }
        let result = EnumTemplate().render(migrationResult)
        
        XCTAssertEqual(result, readResource(Resources.ResultEnumTimeModeDeleted.rawValue))
    }
    
    let renameEnumChange = """
   {
       "summary" : "Here would be a nice summary what changed between versions",
       "api-spec": "OpenAPI",
       "api-type": "REST",
       "from-version" : "0.0.1b",
       "to-version" : "0.0.2",
       "changes" : [
           {
               "object" : {
                   "enum-name" : "TimeRenamedMode"
               },
               "target" : "Signature",
               "original-id" : "TimeMode"
           }
       ]
   }
   """
    
    func testRenamed() {
        let migrationResult = getMigrationResult(
            migration: renameEnumChange,
            target: readResource(Resources.EnumTimeModeRenamed.rawValue)
        )
        let result = EnumTemplate().render(migrationResult)

        XCTAssertEqual(result, readResource(Resources.ResultEnumTimeModeRenamed.rawValue))
    }
    
    let replaceEnumChange = """
   {
       "summary" : "Here would be a nice summary what changed between versions",
       "api-spec": "OpenAPI",
       "api-type": "REST",
       "from-version" : "0.0.1b",
       "to-version" : "0.0.2",
       "changes" : [
           {
               "object" : {
                   "enum-name" : "MessageLevel"
               },
               "target" : "Signature",
               "replacement-id" : "ServiceLevel",
               "custom-convert" : "function conversion(o) { return o === 'INFO' ? 1 : 2 }",
               "custom-revert" : "function conversion(o) { return o === 1 ? 'INFO' : 'ERROR' }",
                "replaced" : {
                    "enum-name" : "ServiceLevel",
                    "type" : "Int"
                }
           }
       ]

   }
   """
    
    func testReplaced() {
        let migrationResult = getMigrationResult(
            migration: replaceEnumChange,
            target: readResource(Resources.EnumMessageLevelFacade.rawValue)
        )
        let result = EnumTemplate().render(migrationResult)

        XCTAssertEqual(result, readResource(Resources.ResultEnumMessageLevelReplaced.rawValue))
    }
    
    enum Resources: String {
        case EnumMessageLevelFacade, EnumPlaceholder, EnumTimeMode, EnumTimeModeFacade, EnumTimeModeDeletedCase, EnumTimeModeRenamed
        case ResultEnumMessageLevelReplaced, ResultEnumTimeMode, ResultEnumTimeModeDeleted, ResultEnumTimeModeDeletedCase, ResultEnumTimeModeRenamed
    }
        
    static var allTests = [
        ("testNoChangeEnum", testNoChangeEnum),
        ("testDeleted", testDeleted),
        ("testDeletedCase", testDeletedCase),
        ("testRenamed", testRenamed),
        ("testReplaced", testReplaced)
    ]
}
