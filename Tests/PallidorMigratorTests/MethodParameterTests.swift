import XCTest
import SourceryFramework
@testable import PallidorMigrator

class MethodParameterTests: XCTestCase {
    override func tearDown() {
        CodeStore.clear()
    }
    
    let replaceMNParameterChange = """
   {
       "summary" : "Here would be a nice summary what changed between versions",
       "api-spec": "OpenAPI",
       "api-type": "REST",
       "from-version" : "0.0.1b",
       "to-version" : "0.0.2",
       "changes" : [
           {
               "object":{
                  "operation-id":"updatePetWithForm",
                  "defined-in":"/pet"
               },
               "target" : "Signature",
               "replacement-id" : "updatePetWithForm",
               "custom-convert" : "function conversion(input) { return JSON.stringify({ 'name': input.name, 'petAndStatus': { 'petId': input.petId, 'status': input.status }} )}",
               "replaced" : {
                  "operation-id":"updatePetWithForm",
                  "defined-in":"/pet"
                }
           }
       ]

   }
   """
    
    func testReplacedMNParametersOfMethod() {
        let fp = try! FileParser(contents: readResource(Resources.PetEndpointReplaceParameter32.rawValue))
        let code = try! fp.parse()
        let current = WrappedTypes(types: code.types)
        
        let fp2 = try! FileParser(contents: readResource(Resources.PetEndpointFacadeReplacedMethod.rawValue))
        let code2 = try! fp2.parse()
        let facade = WrappedTypes(types: code2.types)
        
        CodeStore.initInstance(previous: [facade.getModifiable()!], current: [current.getModifiable()!])
        
        _ = getMigrationResult(migration: replaceMNParameterChange, target: readResource(Resources.PetEndpointReplaceParameter32.rawValue))
        
        let result = APITemplate().render(CodeStore.getInstance().getEndpoint("/pet", searchInCurrent: true)!)
        
        XCTAssertEqual(result, readResource(Resources.ResultPetEndpointFacade32ParameterChange.rawValue))
    }
    
    let replaceM1ParameterChange = """
   {
       "summary" : "Here would be a nice summary what changed between versions",
       "api-spec": "OpenAPI",
       "api-type": "REST",
       "from-version" : "0.0.1b",
       "to-version" : "0.0.2",
       "changes" : [
           {
               "object":{
                  "operation-id":"updatePetWithForm",
                  "defined-in":"/pet"
               },
               "target" : "Signature",
               "replacement-id" : "updatePetWithForm",
               "custom-convert" : "function conversion(input) { return JSON.stringify({ 'name': input.name, 'petId': input.petId } )}",
               "replaced" : {
                  "operation-id":"updatePetWithForm",
                  "defined-in":"/pet"
                }
           }
       ]

   }
   """
    
    func testReplacedM1ParametersOfMethod() {
        let fp = try! FileParser(contents: readResource(Resources.PetEndpointReplaceParameterMN.rawValue))
        let code = try! fp.parse()
        let current = WrappedTypes(types: code.types)
        
        let fp2 = try! FileParser(contents: readResource(Resources.PetEndpointFacadeReplacedMethod.rawValue))
        let code2 = try! fp2.parse()
        let facade = WrappedTypes(types: code2.types)
        
        CodeStore.initInstance(previous: [facade.getModifiable()!], current: [current.getModifiable()!])
        
        _ = getMigrationResult(migration: replaceM1ParameterChange, target: readResource(Resources.PetEndpointReplaceParameterMN.rawValue))
        
        let result = APITemplate().render(CodeStore.getInstance().getEndpoint("/pet", searchInCurrent: true)!)
        
        XCTAssertEqual(result, readResource(Resources.ResultPetEndpointFacadeM1ParameterChange.rawValue))
    }
    
    let replace1NParameterChange = """
   {
       "summary" : "Here would be a nice summary what changed between versions",
       "api-spec": "OpenAPI",
       "api-type": "REST",
       "from-version" : "0.0.1b",
       "to-version" : "0.0.2",
       "changes" : [
           {
               "object":{
                  "operation-id":"updatePet",
                  "defined-in":"/pet"
               },
               "target" : "Signature",
               "replacement-id" : "updatePet",
               "custom-convert" : "function conversion(input) { return JSON.stringify({ 'name': input.name, 'petId': input.petId, 'status': input.status } )}",
               "replaced" : {
                  "operation-id":"updatePet",
                  "defined-in":"/pet"
                }
           }
       ]

   }
   """
    
    func testReplaced1NParametersOfMethod() {
        let fp = try! FileParser(contents: readResource(Resources.PetEndpointReplaceParameterMN.rawValue))
        let code = try! fp.parse()
        let current = WrappedTypes(types: code.types)
        
        let fp2 = try! FileParser(contents: readResource(Resources.PetEndpointFacadeReplacedMethod.rawValue))
        let code2 = try! fp2.parse()
        let facade = WrappedTypes(types: code2.types)
        
        CodeStore.initInstance(previous: [facade.getModifiable()!], current: [current.getModifiable()!])
        
        _ = getMigrationResult(migration: replace1NParameterChange, target: readResource(Resources.PetEndpointReplaceParameterMN.rawValue))
        
        let result = APITemplate().render(CodeStore.getInstance().getEndpoint("/pet", searchInCurrent: true)!)
        
        XCTAssertEqual(result, readResource(Resources.ResultPetEndpointFacade1NParameterChange.rawValue))
    }
    
    let addParameterChange = """
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
    
    let requiringMethodParameterChange = """
   {
       "summary" : "Here would be a nice summary what changed between versions",
       "api-spec": "OpenAPI",
       "api-type": "REST",
       "from-version" : "0.0.1b",
       "to-version" : "0.0.2",
       "changes" : [
           {
               "object" : {
                   "operation-id" : "findPetsByStatus",
                   "defined-in" : "/pet"
               },
               "target" : "Parameter",
               "replacement-id" : "status",
               "type" : "String",
               "replaced" : {
                       "name" : "status",
                       "type" : "String",
                       "default-value" : "available",
                       "required" : true
               }
           }
       ]

   }
   """
    
    /// optional param `petId: Int64` is now  required
    func testRequiringParameter() {
        let migrationResult = getMigrationResult(migration: requiringMethodParameterChange, target: readResource(Resources.PetEndpointRequiringParameter.rawValue))
        let result = APITemplate().render(migrationResult)
        
        XCTAssertEqual(result, readResource(Resources.ResultPetEndpointFacadeRequiredParameter.rawValue))
    }
    
    /// represented as `element` parameter
     let replaceMethodContentBodyChange = """
    {
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
    
    let replaceDefaultValueChange = """
   {
       "summary" : "Here would be a nice summary what changed between versions",
       "api-spec": "OpenAPI",
       "api-type": "REST",
       "from-version" : "0.0.1b",
       "to-version" : "0.0.2",
       "changes" : [
           {
               "object" : {
                   "operation-id" : "findPetsByStatus",
                   "defined-in" : "/pet"
               },
               "target" : "Parameter",
               "replacement-id" : "status",
               "type" : "String",
               "replaced" : {
                       "name" : "status",
                       "type" : "String",
                       "default-value" : "available"
               }
           }
        ]

   }
   """
    
    func testDefaultParameterPetEndpoint() {
        let migrationResult = getMigrationResult(migration: replaceDefaultValueChange, target: readResource(Resources.PetEndpointDefaultParameter.rawValue))
        let result = APITemplate().render(migrationResult)
        
        XCTAssertEqual(result, readResource(Resources.ResultPetEndpointFacadeDefaultParameter.rawValue))
    }
    
    enum Resources: String {
        case PetEndpointAddedParameter, UserEndpointDeletedParameter, PetEndpointRenamedParameter, PetEndpointReplacedParameter, StoreEndpointReplaceContentBody, PetEndpointAddedContentBody, PetEndpointReplacedMethod, PetEndpointFacadeReplacedMethod, PetEndpointReplaceParameterMN, PetEndpointReplaceParameter32, PetEndpointDefaultParameter, PetEndpointRequiringParameter, PetEndpointFacade

        case ResultPetEndpointFacadeAddedParameter, ResultUserEndpointFacadeDeletedParameter, ResultPetEndpointFacadeRenamedParameter, ResultPetEndpointFacadeReplacedParameter, ResultStoreEndpointFacadeReplacedContentBody, ResultPetEndpointFacadeAddedContentBody, ResultPetEndpointFacadeReplacedMethodInSameEndpoint, ResultPetEndpointFacadeM1ParameterChange, ResultPetEndpointFacade1NParameterChange, ResultPetEndpointFacade32ParameterChange, ResultPetEndpointFacadeDefaultParameter, ResultPetEndpointFacadeRequiredParameter
    }
    
    static var allTests = [
        ("testAddedParameter", testAddedParameter),
        ("testDeletedParameter", testDeletedParameter),
        ("testRenamedParameter", testRenamedParameter),
        ("testReplacedParameter", testReplacedParameter),
        ("testReplacedContentBodyStoreEndpoint", testReplacedContentBodyStoreEndpoint),
        ("testAddedContentBodyPetEndpoint", testAddedContentBodyPetEndpoint),
        ("testReplacedM1ParametersOfMethod", testReplacedM1ParametersOfMethod),
        ("testReplacedMNParametersOfMethod", testReplacedMNParametersOfMethod),
        ("testReplaced1NParametersOfMethod", testReplaced1NParametersOfMethod),
        ("testDefaultParameterPetEndpoint", testDefaultParameterPetEndpoint),
        ("testRequiringParameter", testRequiringParameter)
    ]
}
