// Identifier_name linting rule is disabled
// because enum cases reflect the names of corresponding test files
// Force try is disabled for lines that refer to fetching and parsing
// source code with Sourcery. File exceeds normal length due to migration guides.
// Line length exceeds due to convert/revert definition in migration guide
// swiftlint:disable identifier_name file_length type_body_length line_length
import XCTest
import SourceryFramework
@testable import PallidorMigrator

class EndpointIntegrationTests: XCTestCase {
    override func tearDown() {
        CodeStore.clear()
        super.tearDown()
    }
    
    let renameEndpointAndReplaceAndDeleteMethodChange = """
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
                  "defined-in":"/pets"
               },
               "target" : "Signature",
               "replacement-id" : "updatePetWithForm",
               "custom-convert" : "function conversion(o) { return JSON.stringify({ 'type' : 'PSI' } )}",
               "custom-revert" : "function conversion(o) { return JSON.stringify({ 'type': '', 'of' : { 'type': 'PSI'} } )}",
               "replaced" : {
                  "operation-id":"updatePet",
                  "defined-in":"/pet"
                }
           },
           {
               "object" : {
                   "route" : "/pets"
               },
               "target" : "Signature",
               "original-id" : "/pet"
           },
           {
               "object":{
                  "operation-id":"addPet",
                  "defined-in":"/pets"
               },
               "target" : "Signature",
               "fallback-value": { }
           }
       ]
   }
   """
    
    func testRenamedEndpointAndReplaceAndDeleteMethod() {
        // swiftlint:disable:next force_try
        let fp = try! FileParser(contents: readResource(Resources.PetEndpointRenamedAndReplacedAndDeletedMethod.rawValue))
        // swiftlint:disable:next force_try
        let code = try! fp.parse()
        guard let current = WrappedTypes(types: code.types).getModifiable() else {
            fatalError("Could not retrieve current modifiable.")
        }
        
        // swiftlint:disable:next force_try
        let fp2 = try! FileParser(contents: readResource(Resources.PetEndpointFacadeReplacedMethod.rawValue))
        // swiftlint:disable:next force_try
        let code2 = try! fp2.parse()
        let facade = WrappedTypes(types: code2.types)
        
        guard let modifiable = facade.getModifiable() else {
            fatalError("Could not retrieve previous modifiable.")
        }
        
        CodeStore.initInstance(previous: [modifiable], current: [current])
        
        do {
            let sut = try PallidorMigrator(
                targetDirectory: "",
                migrationGuidePath: nil,
                migrationGuideContent: renameEndpointAndReplaceAndDeleteMethodChange
            )
            let modified = try sut.migrationSet.activate(for: current)
            
            let result = APITemplate().render(modified)
            
            XCTAssertEqual(
                result,
                readResource(Resources.ResultPetEndpointFacadeRenamedAndReplacedAndDeletedMethod.rawValue)
            )
        } catch {
            XCTFail("Migration failed.")
        }
    }
    
    let renameEndpointAndReplaceMethodChange = """
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
                  "defined-in":"/pets"
               },
               "target" : "Signature",
               "replacement-id" : "updatePetWithForm",
               "custom-convert" : "function conversion(o) { return JSON.stringify({ 'type' : 'PSI' } )}",
               "custom-revert" : "function conversion(o) { return JSON.stringify({ 'type': '', 'of' : { 'type': 'PSI'} } )}",
               "replaced" : {
                  "operation-id":"updatePet",
                  "defined-in":"/pet"
                }
           },
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
    
    func testRenamedEndpointAndReplaceMethod() {
        // swiftlint:disable:next force_try
        let fp = try! FileParser(contents: readResource(Resources.PetEndpointRenamedAndReplacedMethod.rawValue))
        // swiftlint:disable:next force_try
        let code = try! fp.parse()
        guard let current = WrappedTypes(types: code.types).getModifiable() else {
            fatalError("Could not retrieve current modifiable.")
        }
        
        // swiftlint:disable:next force_try
        let fp2 = try! FileParser(contents: readResource(Resources.PetEndpointFacadeReplacedMethod.rawValue))
        // swiftlint:disable:next force_try
        let code2 = try! fp2.parse()
        let facade = WrappedTypes(types: code2.types)
        
        guard let modifiable = facade.getModifiable() else {
            fatalError("Could not retrieve previous modifiable.")
        }
        
        CodeStore.initInstance(previous: [modifiable], current: [current])
        
        do {
            let sut = try PallidorMigrator(
                targetDirectory: "",
                migrationGuidePath: nil,
                migrationGuideContent: renameEndpointAndReplaceMethodChange
            )
            
            let modified = try sut.migrationSet.activate(for: current)
            
            let result = APITemplate().render(modified)
            
            XCTAssertEqual(
                result,
                readResource(Resources.ResultPetEndpointFacadeRenamedAndReplacedMethod.rawValue)
            )
        } catch {
            XCTFail("Migration failed.")
        }
    }
    
    let renameEndpointAndDeletedMethodChange = """
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
           },
           {
               "object":{
                  "operation-id":"updatePet",
                  "defined-in":"/pets"
               },
               "target" : "Signature",
               "fallback-value": { }
           }
       ]
   }
   """
    
    func testRenamedEndpointAndDeletedMethod() {
        // swiftlint:disable:next force_try
        let fp = try! FileParser(contents: readResource(Resources.PetEndpointRenamedAndReplacedMethod.rawValue))
        // swiftlint:disable:next force_try
        let code = try! fp.parse()
        
        guard let current = WrappedTypes(types: code.types).getModifiable() else {
            fatalError("Could not retrieve current modifiable.")
        }
        
        // swiftlint:disable:next force_try
        let fp2 = try! FileParser(contents: readResource(Resources.PetEndpointFacadeReplacedMethod.rawValue))
        // swiftlint:disable:next force_try
        let code2 = try! fp2.parse()
        let facade = WrappedTypes(types: code2.types)
        
        guard let modifiable = facade.getModifiable() else {
            fatalError("Could not retrieve previous modifiable.")
        }
        
        CodeStore.initInstance(previous: [modifiable], current: [current])
        
        do {
            let sut = try PallidorMigrator(
                targetDirectory: "",
                migrationGuidePath: nil,
                migrationGuideContent: renameEndpointAndDeletedMethodChange
            )
            
            let modified = try sut.migrationSet.activate(for: current)
            
            let result = APITemplate().render(modified)
            
            XCTAssertEqual(
                result,
                readResource(Resources.ResultPetEndpointFacadeRenamedAndDeletedMethod.rawValue)
            )
        } catch {
            XCTFail("Migration failed.")
        }
    }
    
    let renameEndpointAndRenameMethodChange = """
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
                  "operation-id" : "addMyPet",
                  "defined-in" : "/pets"
              },
              "target" : "Signature",
              "original-id" : "addPet"
           },
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
    
    func testRenamedEndpointAndRenamedMethod() {
        CodeStore.initInstance(previous: [], current: [])

        let modified = getMigrationResult(
            migration: renameEndpointAndRenameMethodChange,
            target: readResource(Resources.PetEndpointRenamedAndRenamedMethod.rawValue)
        )
        
        let result = APITemplate().render(modified)
        
        XCTAssertEqual(
            result,
            readResource(Resources.ResultPetEndpointFacadeRenamedAndRenamedMethod.rawValue)
        )
    }
    
    let renamedEndpointAndRenameMethodAndReplaceAndDeleteParameterChange = """
   {
       "summary" : "Here would be a nice summary what changed between versions",
       "api-spec": "OpenAPI",
       "api-type": "REST",
       "from-version" : "0.0.1b",
       "to-version" : "0.0.2",
       "changes" : [
            {
               "object":{
                  "operation-id":"updatePetWithFormNew",
                  "defined-in":"/pets"
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
                    "defined-in" : "/pets"
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
                   "defined-in" : "/pets"
               },
               "target" : "Signature",
               "original-id" : "updatePetWithForm"
           },
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
    
    func testRenamedEndpointAndRenameMethodAndReplaceAndDeleteParameterChange() {
        CodeStore.initInstance(previous: [], current: [])

        let modified = getMigrationResult(
            migration: renamedEndpointAndRenameMethodAndReplaceAndDeleteParameterChange,
            target: readResource(Resources
                                    .PetEndpointRenamedAndRenamedMethodAndReplacedParameter.rawValue)
        )
        
        let result = APITemplate().render(modified)
        
        XCTAssertEqual(
            result,
            readResource(Resources
                            .ResultPetEndpointFacadeRenamedAndRenamedMethodAndReplacedParameter.rawValue)
        )
    }
    
    let renamedEndpointAndRenameMethodAndAddAndDeleteParameterChange = """
   {
       "summary" : "Here would be a nice summary what changed between versions",
       "api-spec": "OpenAPI",
       "api-type": "REST",
       "from-version" : "0.0.1b",
       "to-version" : "0.0.2",
       "changes" : [
            {
               "object":{
                  "operation-id":"updatePetWithFormNew",
                  "defined-in":"/pets"
               },
               "target":"Parameter",
               "fallback-value" : {
                   "name" : "status",
                   "type" : "String",
                   "required" : "true"
               }
            },
           {
               "reason": "Security issue related change",
               "object" : {
                   "operation-id" : "updatePetWithFormNew",
                   "defined-in" : "/pets"
               },
               "target" : "Content-Body",
               "added" : [
                   {
                       "name" : "_",
                       "type" : "Pet",
                       "default-value" : "{ 'name' : 'Mrs. Fluffy', 'photoUrls': ['xxx'] }"
                   }
               ]
           },
           {
               "object" : {
                   "operation-id" : "updatePetWithFormNew",
                   "defined-in" : "/pets"
               },
               "target" : "Signature",
               "original-id" : "updatePetWithForm"
           },
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
    
    func testRenamedEndpointAndRenameMethodAndAddAndDeleteParameterChange() {
        CodeStore.initInstance(previous: [], current: [])

        let modified = getMigrationResult(
            migration: renamedEndpointAndRenameMethodAndAddAndDeleteParameterChange,
            target: readResource(Resources
                                    .PetEndpointRenamedAndRenamedMethodAndAddedAndDeletedParameter.rawValue)
        )
        
        let result = APITemplate().render(modified)
        
        XCTAssertEqual(
            result,
            readResource(Resources.ResultPetEndpointFacadeRenamedMethodAndAddedAndDeletedParameter.rawValue)
        )
    }
    
    let renamedEndpointAndRenameMethodAndReplaceAndDeleteParameterAndReplaceReturnValueChange = """
   {
       "summary" : "Here would be a nice summary what changed between versions",
       "api-spec": "OpenAPI",
       "api-type": "REST",
       "from-version" : "0.0.1b",
       "to-version" : "0.0.2",
       "changes" : [
            {
               "object":{
                  "operation-id":"updatePetWithFormNew",
                  "defined-in":"/pets"
               },
               "target":"ReturnValue",
               "replacement-id":"_",
               "type":"Pet",
               "custom-revert":"function conversion(response) { var response = JSON.parse(response) return JSON.stringify({ 'id' : response.code, 'name' : response.message, 'photoUrls': [response.type], 'status' : 'available', 'tags': [ { 'id': 27, 'name': 'tag2' } ] }) }",
               "replaced":{
                  "name":"_",
                  "type":"String"
               }
            },
            {
               "object":{
                  "operation-id":"updatePetWithFormNew",
                  "defined-in":"/pets"
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
                    "defined-in" : "/pets"
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
                   "defined-in" : "/pets"
               },
               "target" : "Signature",
               "original-id" : "updatePetWithForm"
           },
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
    
    func testRenamedEndpointAndRenameMethodAndReplaceAndDeleteParameterAndReplaceReturnValueChange() {
        CodeStore.initInstance(previous: [], current: [])

        let modified = getMigrationResult(
            migration: renamedEndpointAndRenameMethodAndReplaceAndDeleteParameterAndReplaceReturnValueChange,
            target:
                readResource(Resources.PetEndpointRenamedAndRenamedMethodAndReplacedAndDeletedParameterAndReplacedReturnValue.rawValue)
        )
        
        let result = APITemplate().render(modified)
        
        XCTAssertEqual(
            result,
            readResource(Resources.ResultPetEndpointFacadeRenamedAndRenamedMethodAndReplacedParameterAndReplacedReturnValue.rawValue)
        )
    }

    let renamedEndpointAndRenameMethodAndChangedParametersAndReplaceReturnValueChange = """
   {
       "summary" : "Here would be a nice summary what changed between versions",
       "api-spec": "OpenAPI",
       "api-type": "REST",
       "from-version" : "0.0.1b",
       "to-version" : "0.0.2",
       "changes" : [
            {
               "object":{
                  "operation-id":"updatePetWithFormNew",
                  "defined-in":"/pets"
               },
               "target":"ReturnValue",
               "replacement-id":"_",
               "type":"Pet",
               "custom-revert":"function conversion(response) { var response = JSON.parse(response) return JSON.stringify({ 'id' : response.code, 'name' : response.message, 'photoUrls': [response.type], 'status' : 'available', 'tags': [ { 'id': 27, 'name': 'tag2' } ] }) }",
               "replaced":{
                  "name":"_",
                  "type":"String"
               }
            },
           {
               "object" : {
                   "operation-id" : "updatePetWithFormNew",
                   "defined-in" : "/pets"
               },
               "target" : "Parameter",
               "original-id" : "petName",
               "renamed" : {
                   "id": "name"
               }
           },
            {
               "object":{
                  "operation-id":"updatePetWithFormNew",
                  "defined-in":"/pets"
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
                    "defined-in" : "/pets"
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
                   "defined-in" : "/pets"
               },
               "target" : "Signature",
               "original-id" : "updatePetWithForm"
           },
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
    
    func testRenamedEndpointAndRenameMethodAndChangedParametersAndReplaceReturnValueChange() {
        CodeStore.initInstance(previous: [], current: [])

        let modified = getMigrationResult(
            migration: renamedEndpointAndRenameMethodAndChangedParametersAndReplaceReturnValueChange,
            target: readResource(Resources
                                    .PetEndpointRenamedAndRenamedMethodAndChangedParametersAndReplacedReturnValue
                                    .rawValue)
        )
        
        let result = APITemplate().render(modified)
        
        XCTAssertEqual(
            result,
            readResource(Resources
                            .ResultPetEndpointFacadeRenamedAndRenamedMethodAndChangedParametersAndReplacedReturnValue
                            .rawValue)
        )
    }
    
    enum Resources: String {
        case PetEndpointRenamedAndReplacedMethod, PetEndpointFacadeReplacedMethod, PetEndpointRenamedAndRenamedMethod, PetEndpointRenamedAndRenamedMethodAndReplacedParameter, PetEndpointRenamedAndReplacedAndDeletedMethod, PetEndpointRenamedAndRenamedMethodAndAddedAndDeletedParameter, PetEndpointRenamedAndRenamedMethodAndReplacedAndDeletedParameterAndReplacedReturnValue, PetEndpointRenamedAndRenamedMethodAndChangedParametersAndReplacedReturnValue
        case ResultPetEndpointFacadeRenamedAndReplacedMethod, ResultPetEndpointFacadeRenamedAndRenamedMethod, ResultPetEndpointFacadeRenamedAndDeletedMethod, ResultPetEndpointFacadeRenamedAndRenamedMethodAndReplacedParameter, ResultPetEndpointFacadeRenamedAndReplacedAndDeletedMethod, ResultPetEndpointFacadeRenamedMethodAndAddedAndDeletedParameter, ResultPetEndpointFacadeRenamedAndRenamedMethodAndReplacedParameterAndReplacedReturnValue, ResultPetEndpointFacadeRenamedAndRenamedMethodAndChangedParametersAndReplacedReturnValue
    }
    
    static var allTests = [
        ("testRenamedEndpointAndReplaceMethod", testRenamedEndpointAndReplaceMethod),
        ("testRenamedEndpointAndDeletedMethod", testRenamedEndpointAndDeletedMethod),
        ("testRenamedEndpointAndRenamedMethod", testRenamedEndpointAndRenamedMethod),
        ("testRenamedEndpointAndReplaceAndDeleteMethod", testRenamedEndpointAndReplaceAndDeleteMethod),
        ("testRenamedEndpointAndRenameMethodAndReplaceAndDeleteParameterChange", testRenamedEndpointAndRenameMethodAndReplaceAndDeleteParameterChange),
        ("testRenamedEndpointAndRenameMethodAndReplaceAndDeleteParameterAndReplaceReturnValueChange", testRenamedEndpointAndRenameMethodAndReplaceAndDeleteParameterAndReplaceReturnValueChange),
        ("testRenamedEndpointAndRenameMethodAndAddAndDeleteParameterChange", testRenamedEndpointAndRenameMethodAndAddAndDeleteParameterChange),
        ("testRenamedEndpointAndRenameMethodAndChangedParametersAndReplaceReturnValueChange", testRenamedEndpointAndRenameMethodAndChangedParametersAndReplaceReturnValueChange)
    ]
}
