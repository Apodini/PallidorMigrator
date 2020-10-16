import XCTest
import SourceryFramework
@testable import PallidorMigrator

class MethodIntegrationTests: XCTestCase {
    override func tearDown() {
        CodeStore.clear()
    }
    
    let renameMethodAndReplaceAndDeleteParameterChange = """
   {
       "lang" : "Swift",
       "summary" : "Here would be a nice summary what changed between versions",
       "api-spec": "OpenAPI",
       "api-type": "REST",
       "from-version" : "0.0.1b",
       "to-version" : "0.0.2",
       "changes" : [
            {
               "object":{
                  "operation-id":"updatePetWithFormNew",
                  "defined-in":"/pet"
               },
               "target":"Parameter",
               "fallback-value" : {
                   "name" : "status",
                   "type" : "String",
                   "required" : "true"
               }
            },
            {
                "object" : {
                    "operation-id" : "updatePetWithFormNew",
                    "defined-in" : "/pet"
                },
                "target" : "Parameter",
                "replacement-id" : "betterId",
                "type" : "String",
                "custom-convert" : "function conversion(petId) { return 'Id#' + (petId + 1.86) }",
                "custom-revert" : "function conversion(petId) { return Int(petId) }",
                "replaced" : {
                        "name" : "petId",
                        "type" : "Int64",
                        "required" : true
                }
            },
           {
               "object" : {
                   "operation-id" : "updatePetWithFormNew",
                   "defined-in" : "/pet"
               },
               "target" : "Signature",
               "original-id" : "updatePetWithForm"
           }
       ]
   }
   """
    
    func testRenamedMethodAndReplacedAndDeletedParameter() {
        let migrationResult = getMigrationResult(migration: renameMethodAndReplaceAndDeleteParameterChange, target: readResource(Resources.PetEndpointRenamedMethodAndReplacedParameter.rawValue))
        let result = APITemplate().render(migrationResult)

        XCTAssertEqual(result, readResource(Resources.ResultPetEndpointFacadeRenamedMethodAndReplacedDeletedParameter.rawValue))
    }
    
    let renameMethodAndDeleteParameterChange = """
   {
       "lang" : "Swift",
       "summary" : "Here would be a nice summary what changed between versions",
       "api-spec": "OpenAPI",
       "api-type": "REST",
       "from-version" : "0.0.1b",
       "to-version" : "0.0.2",
       "changes" : [
            {
               "object":{
                  "operation-id":"addMyPet",
                  "defined-in":"/pet"
               },
               "target":"Content-Body",
               "fallback-value" : {
                   "name" : "_",
                   "type" : "Pet"
               }
            },
           {
               "object" : {
                   "operation-id" : "addMyPet",
                   "defined-in" : "/pet"
               },
               "target" : "Signature",
               "original-id" : "addPet"
           }
       ]
   }
   """

    func testRenamedMethodAndDeletedParameter() {
        let migrationResult = getMigrationResult(migration: renameMethodAndDeleteParameterChange, target: readResource(Resources.PetEndpointRenamedMethodAndDeletedParameter.rawValue))
        let result = APITemplate().render(migrationResult)

        XCTAssertEqual(result, readResource(Resources.ResultPetEndpointFacadeRenamedMethodAndDeletedParameter.rawValue))
    }
    
    let renameMethodAndReplacedReturnValueChange = """
   {
       "lang" : "Swift",
       "summary" : "Here would be a nice summary what changed between versions",
       "api-spec": "OpenAPI",
       "api-type": "REST",
       "from-version" : "0.0.1b",
       "to-version" : "0.0.2",
       "changes" : [
            {
               "object":{
                  "operation-id":"addMyPet",
                  "defined-in":"/pet"
               },
               "target":"ReturnValue",
               "replacement-id":"_",
               "type":"Order",
               "custom-revert":"function conversion(response) { var response = JSON.parse(response) return JSON.stringify({ 'id' : response.code, 'name' : response.message, 'photoUrls': [response.type], 'status' : 'available', 'tags': [ { 'id': 27, 'name': 'tag2' } ] }) }",
               "replaced":{
                  "name":"_",
                  "type":"Pet"
               }
            },
           {
               "reason": "Security issue related change",
               "object" : {
                   "operation-id" : "addMyPet",
                   "defined-in" : "/pet"
               },
               "target" : "Signature",
               "original-id" : "addPet"
           }
       ]
   }
   """

    func testRenamedMethodAndReplacedReturnValue() {
        let migrationResult = getMigrationResult(migration: renameMethodAndReplacedReturnValueChange, target: readResource(Resources.PetEndpointRenamedMethodAndReplacedReturnValue.rawValue))
        let result = APITemplate().render(migrationResult)

        XCTAssertEqual(result, readResource(Resources.ResultPetEndpointRenamedMethodAndReplacedReturnValue.rawValue))
    }
    
    enum Resources: String {
        case PetEndpointRenamedMethodAndReplacedReturnValue, PetEndpointRenamedMethodAndDeletedParameter, PetEndpointRenamedMethodAndReplacedParameter
        case ResultPetEndpointRenamedMethodAndReplacedReturnValue, ResultPetEndpointFacadeRenamedMethodAndDeletedParameter,
             ResultPetEndpointFacadeRenamedMethodAndReplacedDeletedParameter
    }
    
    static var allTests = [
        ("testRenamedMethodAndDeletedParameter", testRenamedMethodAndDeletedParameter),
        ("testRenamedMethodAndReplacedReturnValue", testRenamedMethodAndReplacedReturnValue),
        ("testRenamedMethodAndReplacedAndDeletedParameter", testRenamedMethodAndReplacedAndDeletedParameter)
    ]
}
