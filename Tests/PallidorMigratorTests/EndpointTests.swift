// Identifier_name linting rule is disabled
// because enum cases reflect the names of corresponding test files
// Force try is disabled for lines that refer to fetching and parsing
// source code with Sourcery. File exceeds normal length due to migration guides.
// Line length exceeds due to convert/revert definition in migration guide
// swiftlint:disable identifier_name
import XCTest
import SourceryFramework
@testable import PallidorMigrator

class EndpointTests: XCTestCase {
    override func tearDown() {
        CodeStore.clear()
        super.tearDown()
    }
    
    let renameEndpointChange = """
   {
       "summary" : "Here would be a nice summary what changed between versions",
       "api-spec": "OpenAPI",
       "api-type": "REST",
       "from-version" : "0.0.1b",
       "to-version" : "0.0.2",
       "changes" : [
           {
               "object" : {
                   "route" : "/pets"
               },
               "target" : "Signature",
               "original-id" : "/pet"
           }
       ]
   }
   """
    
    func testEndpointRenamed() {
        CodeStore.initInstance(previous: [], current: [])
        let migrationResult = getMigrationResult(
            migration: renameEndpointChange,
            target: readResource(Resources.PetEndpointRenamed.rawValue)
        )
        let result = APITemplate().render(migrationResult)
        
        XCTAssertEqual(result, readResource(Resources.ResultPetEndpointFacadeRenamed.rawValue))
    }
        
    func testRenamedAndAddMethod() {
        // swiftlint:disable:next force_try
        let fp = try! FileParser(contents: readResource(Resources.PetEndpointFacadeAddMethod.rawValue))
        // swiftlint:disable:next force_try
        let code = try! fp.parse()
        guard let facade = WrappedTypes(types: code.types).getModifiable() else {
            fatalError("Could not retrieve previous modifiable.")
        }
        
        CodeStore.initInstance(previous: [facade], current: [])
        let migrationResult = getMigrationResult(
            migration: renameEndpointChange,
            target: readResource(Resources.PetEndpointRenamed.rawValue)
        )
        let result = APITemplate().render(migrationResult)
        
        XCTAssertEqual(result, readResource(Resources.ResultPetEndpointFacadeRenamed.rawValue))
    }
    
    let deleteEndpointChange = """
   {
       "summary" : "Here would be a nice summary what changed between versions",
       "api-spec": "OpenAPI",
       "api-type": "REST",
       "from-version" : "0.0.1b",
       "to-version" : "0.0.2",
       "changes" : [
           {
               "object" : {
                   "route" : "/pet"
               },
               "target" : "Signature",
               "fallback-value" : {
                   "name" : "/pet"
               }
           }
       ]
   }
   """
    
    func testDeleted() {
        // swiftlint:disable:next force_try
        let fp = try! FileParser(contents: readResource(Resources.PetEndpointFacade.rawValue))
        // swiftlint:disable:next force_try
        let code = try! fp.parse()
        guard let facade = WrappedTypes(types: code.types).getModifiable() else {
            fatalError("Could not retrieve previous modifiable.")
        }
        
        CodeStore.initInstance(previous: [facade], current: [])
        
        /// irrelevant for deleted migration
        _ = getMigrationResult(
            migration: deleteEndpointChange,
            target: readResource(Resources.EndpointPlaceholder.rawValue)
        )
        
        guard let migrationResult = CodeStore
                .getInstance()
                .getEndpoint(facade.id, searchInCurrent: true) else {
            fatalError("Migration failed.")
        }
        
        let result = APITemplate().render(migrationResult)

        XCTAssertEqual(result, readResource(Resources.ResultPetEndpointFacadeDeleted.rawValue))
    }
    
    let renameMethodAndChangeContentBodyChange = """
   {
       "summary" : "Here would be a nice summary what changed between versions",
       "api-spec": "OpenAPI",
       "api-type": "REST",
       "from-version" : "0.0.1b",
       "to-version" : "0.0.2",
       "changes" : [
           {
               "reason": "Security issue related change",
               "object" : {
                   "operation-id" : "updateMyPet",
                   "defined-in" : "/pet"
               },
               "target" : "Signature",
               "original-id" : "updatePet"
           },
            {
                "object" : {
                   "operation-id" : "updatePet",
                   "defined-in" : "/pet"
                },
                "target" : "Content-Body",
                "replacement-id" : "_",
                "type" : "Order",
                "custom-convert" : "function conversion(placeholder) { return placeholder }",
                "custom-revert" : "function conversion(placeholder) { return placeholder }",
                "replaced" : {
                        "name" : "_",
                        "type" : "Pet",
                        "required" : true
                }
            }
       ]

   }
   """
    
    /// method `updatePet()` is renamed to `updateMyPet()`
    /// parameter changed, return value remain the same
    func testRenameMethodAndChangeContentBodyChange() {
        let migrationResult = getMigrationResult(
            migration: renameMethodAndChangeContentBodyChange,
            target: readResource(Resources.PetEndpointRenamedMethodAndContentBody.rawValue)
        )
        let result = APITemplate().render(migrationResult)
        
        XCTAssertEqual(result, readResource(
                        Resources.ResultPetEndpointFacadeRenamedMethodAndContentBody.rawValue)
        )
    }

    enum Resources: String {
        case PetEndpointRenamed, PetEndpointFacade, EndpointPlaceholder, PetEndpointRenamedMethodAndContentBody, PetEndpointFacadeAddMethod
        case ResultPetEndpointFacadeRenamed, ResultPetEndpointFacadeDeleted, ResultPetEndpointFacadeRenamedMethodAndContentBody
    }
    
    static var allTests = [
        ("testDeleted", testDeleted),
        ("testEndpointRenamed", testEndpointRenamed),
        ("testRenameMethodAndChangeContentBodyChange", testRenameMethodAndChangeContentBodyChange)
    ]
}
