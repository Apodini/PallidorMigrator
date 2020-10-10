import XCTest
import SourceryFramework
@testable import PallidorMigrator

class MethodParameterTests: XCTestCase {
    override func tearDown() {
        CodeStore.clear()
    }
    
    let addParameterChange = """
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
                   "operation-id" : "updatePet",
                   "defined-in" : "/pet"
               },
               "target" : "Parameter",
               "added" : [
                   {
                       "name" : "status",
                       "type" : "String",
                       "default-value" : "available"
                   }
               ]
           }
       ]

   }
   """
    
    /// has added param `status: String` to `updatePet()`
    func testAddedParameter() {
        let migrationResult = getMigrationResult(migration: addParameterChange, target: readResource( Resources.PetEndpointAddedParameter.rawValue))
        let result = APITemplate().render(migrationResult)
        
        XCTAssertEqual(result, readResource(Resources.ResultPetEndpointFacadeAddedParameter.rawValue))
    }
    
    let deleteParameterChange = """
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
                   "operation-id" : "updateUser",
                   "defined-in" : "/user"
               },
               "target" : "Parameter",
               "fallback-value" : {
                   "name" : "username",
                   "type" : "String"
               }
           }
       ]

   }
   """
    
    func testDeletedParameter() {
        let migrationResult = getMigrationResult(migration: deleteParameterChange, target: readResource(Resources.UserEndpointDeletedParameter.rawValue))
        let result = APITemplate().render(migrationResult)
        
        XCTAssertEqual(result, readResource(Resources.ResultUserEndpointFacadeDeletedParameter.rawValue))
    }
    
    let renameMethodParameterChange = """
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
                   "operation-id" : "findPetsByStatus",
                   "defined-in" : "/pet"
               },
               "target" : "Parameter",
               "original-id" : "status",
               "renamed" : {
                   "id": "petStatus"
               }
           }
       ]

   }
   """
    
    func testRenamedParameter() {
        let migrationResult = getMigrationResult(migration: renameMethodParameterChange, target: readResource(Resources.PetEndpointRenamedParameter.rawValue))
        let result = APITemplate().render(migrationResult)
        
        XCTAssertEqual(result, readResource(Resources.ResultPetEndpointFacadeRenamedParameter.rawValue))
    }
    
    let replaceMethodParameterChange = """
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
                   "operation-id" : "updatePetWithForm",
                   "defined-in" : "/pet"
               },
               "target" : "Parameter",
               "replacement-id" : "betterId",
               "type" : "Double",
               "custom-convert" : "function conversion(petId) { return (petId + 1.86) }",
               "custom-revert" : "function conversion(petId) { return (petId + 1.86) }",
               "replaced" : {
                       "name" : "petId",
                       "type" : "Int64",
                       "required" : true
               }
           }
       ]

   }
   """
    
    /// replaced param `petId: Int64` with `betterId: Double` in `updatePetWithForm()`
    func testReplacedParameter() {
        let migrationResult = getMigrationResult(migration: replaceMethodParameterChange, target: readResource(Resources.PetEndpointReplacedParameter.rawValue))
        let result = APITemplate().render(migrationResult)
        
        XCTAssertEqual(result, readResource(Resources.ResultPetEndpointFacadeReplacedParameter.rawValue))
    }
    
    /// represented as `element` parameter
     let replaceMethodContentBodyChange = """
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
                    "operation-id" : "placeOrder",
                    "defined-in" : "/store"
                },
                "target" : "Content-Body",
                "replacement-id" : "_",
                "type" : "Customer",
                "custom-convert" : "function conversion(placeholder) { return placeholder }",
                "custom-revert" : "function conversion(placeholder) { return placeholder }",
                "replaced" : {
                        "name" : "_",
                        "type" : "Order",
                        "required" : true
                }
            }
        ]

    }
    """
    
    /// method `placeOrder` now has content-type of `Customer` instead of `Order`
    func testReplacedContentBodyStoreEndpoint() {
        let migrationResult = getMigrationResult(migration: replaceMethodContentBodyChange, target: readResource(Resources.StoreEndpointReplaceContentBody.rawValue))
        let result = APITemplate().render(migrationResult)
        
        XCTAssertEqual(result, readResource(Resources.ResultStoreEndpointFacadeReplacedContentBody.rawValue))
    }
    
    let addContentBodyChange = """
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
                   "operation-id" : "findPetsByStatus",
                   "defined-in" : "/pet"
               },
               "target" : "Content-Body",
               "added" : [
                   {
                       "name" : "_",
                       "type" : "Pet",
                       "default-value" : "{ 'name' : 'Mrs. Fluffy', 'photoUrls': ['xxx'] }"
                   }
               ]
           }
       ]

   }
   """
    
    /// method `findPetsByStatus` has a new content-type of `Pet`
    func testAddedContentBodyPetEndpoint() {
        let migrationResult = getMigrationResult(migration: addContentBodyChange, target: readResource(Resources.PetEndpointAddedContentBody.rawValue))
        let result = APITemplate().render(migrationResult)
        
        XCTAssertEqual(result, readResource(Resources.ResultPetEndpointFacadeAddedContentBody.rawValue))
    }
    
    enum Resources: String {
        case PetEndpointAddedParameter, UserEndpointDeletedParameter, PetEndpointRenamedParameter, PetEndpointReplacedParameter, StoreEndpointReplaceContentBody, PetEndpointAddedContentBody

        case ResultPetEndpointFacadeAddedParameter, ResultUserEndpointFacadeDeletedParameter, ResultPetEndpointFacadeRenamedParameter, ResultPetEndpointFacadeReplacedParameter, ResultStoreEndpointFacadeReplacedContentBody, ResultPetEndpointFacadeAddedContentBody
    }
    
    static var allTests = [
        ("testAddedParameter", testAddedParameter),
        ("testDeletedParameter", testDeletedParameter),
        ("testRenamedParameter", testRenamedParameter),
        ("testReplacedParameter", testReplacedParameter),
        ("testReplacedContentBodyStoreEndpoint", testReplacedContentBodyStoreEndpoint),
        ("testAddedContentBodyPetEndpoint", testAddedContentBodyPetEndpoint)
    ]
}
