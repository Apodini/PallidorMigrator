import XCTest
import SourceryFramework
@testable import PallidorMigrator

class EndpointTests: XCTestCase {
    
    override func tearDown() {
        CodeStore.clear()
    }
    
    let renameEndpointChange = """
   {
       "lang" : "Swift",
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
    
    func testRenamed() {
        let migrationResult = getMigrationResult(migration: renameEndpointChange, target: readResource(Resources.PetEndpointRenamed.rawValue))
        let result = APITemplate().render(migrationResult)
        
        XCTAssertEqual(result, readResource(Resources.ResultPetEndpointFacadeRenamed.rawValue))
    }
    
    let deleteEndpointChange = """
   {
       "lang" : "Swift",
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
        let fp = try! FileParser(contents: readResource(Resources.PetEndpointFacade.rawValue))
        let code = try! fp.parse()
        let facade = WrappedTypes(types: code.types)
        
        CodeStore.initInstance(previous: [facade.getModifiable()!], current: [])
        
        /// irrelevant for deleted migration
        _ = getMigrationResult(migration: deleteEndpointChange, target: readResource(Resources.EndpointPlaceholder.rawValue))
        
        let migrationResult = CodeStore.getInstance().getEndpoint(facade.getModifiable()!.id, searchInCurrent: true)!
        
        let result = APITemplate().render(migrationResult)

        XCTAssertEqual(result, readResource(Resources.ResultPetEndpointFacadeDeleted.rawValue))
    }
    
    let renameMethodAndChangeContentBodyChange = """
   {
       "lang" : "Swift",
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
        let migrationResult = getMigrationResult(migration: renameMethodAndChangeContentBodyChange, target: readResource(Resources.PetEndpointRenamedMethodAndContentBody.rawValue))
        let result = APITemplate().render(migrationResult)
        
        XCTAssertEqual(result, readResource(Resources.ResultPetEndpointFacadeRenamedMethodAndContentBody.rawValue))
    }

    enum Resources: String {
        case PetEndpointRenamed, PetEndpointFacade, EndpointPlaceholder, PetEndpointRenamedMethodAndContentBody
        case ResultPetEndpointFacadeRenamed, ResultPetEndpointFacadeDeleted, ResultPetEndpointFacadeRenamedMethodAndContentBody
    }
    
    static var allTests = [
        ("testDeleted", testDeleted),
        ("testRenamed", testRenamed),
        ("testRenameMethodAndChangeContentBodyChange", testRenameMethodAndChangeContentBodyChange)
    ]
}
