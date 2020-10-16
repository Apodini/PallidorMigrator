import XCTest
import SourceryFramework
@testable import PallidorMigrator

class EndpointIntegrationTests: XCTestCase {
    
    override func tearDown() {
        CodeStore.clear()
    }
    
    let renameEndpointAndReplaceAndDeleteMethodChange = """
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
        let fp = try! FileParser(contents: readResource(Resources.PetEndpointRenamedAndReplacedAndDeletedMethod.rawValue))
        let code = try! fp.parse()
        let current = WrappedTypes(types: code.types).getModifiable()!
        
        let fp2 = try! FileParser(contents: readResource(Resources.PetEndpointFacadeReplacedMethod.rawValue))
        let code2 = try! fp2.parse()
        let facade = WrappedTypes(types: code2.types)
        
        
        CodeStore.initInstance(previous: [facade.getModifiable()!], current: [current])
        
        let sut = try! PallidorMigrator(targetDirectory: "", migrationGuidePath: nil, migrationGuideContent: renameEndpointAndReplaceAndDeleteMethodChange)
        
        let modified = try! sut.migrationSet.activate(for: current)
        
        let result = APITemplate().render(modified)
        
        XCTAssertEqual(result, readResource(Resources.ResultPetEndpointFacadeRenamedAndReplacedAndDeletedMethod.rawValue))
    }
    
    let renameEndpointAndReplaceMethodChange = """
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
        let fp = try! FileParser(contents: readResource(Resources.PetEndpointRenamedAndReplacedMethod.rawValue))
        let code = try! fp.parse()
        let current = WrappedTypes(types: code.types).getModifiable()!
        
        let fp2 = try! FileParser(contents: readResource(Resources.PetEndpointFacadeReplacedMethod.rawValue))
        let code2 = try! fp2.parse()
        let facade = WrappedTypes(types: code2.types)
        
        
        CodeStore.initInstance(previous: [facade.getModifiable()!], current: [current])
        
        let sut = try! PallidorMigrator(targetDirectory: "", migrationGuidePath: nil, migrationGuideContent: renameEndpointAndReplaceMethodChange)
        
        let modified = try! sut.migrationSet.activate(for: current)
        
        let result = APITemplate().render(modified)
        
        XCTAssertEqual(result, readResource(Resources.ResultPetEndpointFacadeRenamedAndReplacedMethod.rawValue))
    }
    
    let renameEndpointAndDeletedMethodChange = """
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
        let fp = try! FileParser(contents: readResource(Resources.PetEndpointRenamedAndReplacedMethod.rawValue))
        let code = try! fp.parse()
        let current = WrappedTypes(types: code.types).getModifiable()!
        
        let fp2 = try! FileParser(contents: readResource(Resources.PetEndpointFacadeReplacedMethod.rawValue))
        let code2 = try! fp2.parse()
        let facade = WrappedTypes(types: code2.types)
        
        CodeStore.initInstance(previous: [facade.getModifiable()!], current: [current])
        
        let sut = try! PallidorMigrator(targetDirectory: "", migrationGuidePath: nil, migrationGuideContent: renameEndpointAndDeletedMethodChange)
        
        let modified = try! sut.migrationSet.activate(for: current)
        
        let result = APITemplate().render(modified)
        
        XCTAssertEqual(result, readResource(Resources.ResultPetEndpointFacadeRenamedAndDeletedMethod.rawValue))
    }
    
    let renameEndpointAndRenameMethodChange = """
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

        let modified = getMigrationResult(migration: renameEndpointAndRenameMethodChange, target: readResource(Resources.PetEndpointRenamedAndRenamedMethod.rawValue))
        
        let result = APITemplate().render(modified)
        
        XCTAssertEqual(result, readResource(Resources.ResultPetEndpointFacadeRenamedAndRenamedMethod.rawValue))
    }
    
    let renamedEndpointAndRenameMethodAndReplaceAndDeleteParameterChange = """
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

        let modified = getMigrationResult(migration: renamedEndpointAndRenameMethodAndReplaceAndDeleteParameterChange, target: readResource(Resources.PetEndpointRenamedAndRenamedMethodAndReplacedParameter.rawValue))
        
        let result = APITemplate().render(modified)
        
        XCTAssertEqual(result, readResource(Resources.ResultPetEndpointFacadeRenamedAndRenamedMethodAndReplacedParameter.rawValue))
    }

    enum Resources: String {
        case PetEndpointRenamedAndReplacedMethod, PetEndpointFacadeReplacedMethod, PetEndpointRenamedAndRenamedMethod, PetEndpointRenamedAndRenamedMethodAndReplacedParameter, PetEndpointRenamedAndReplacedAndDeletedMethod
        case ResultPetEndpointFacadeRenamedAndReplacedMethod, ResultPetEndpointFacadeRenamedAndRenamedMethod, ResultPetEndpointFacadeRenamedAndDeletedMethod, ResultPetEndpointFacadeRenamedAndRenamedMethodAndReplacedParameter, ResultPetEndpointFacadeRenamedAndReplacedAndDeletedMethod
    }
    
    static var allTests = [
        ("testRenamedEndpointAndReplaceMethod", testRenamedEndpointAndReplaceMethod),
        ("testRenamedEndpointAndDeletedMethod", testRenamedEndpointAndDeletedMethod),
        ("testRenamedEndpointAndRenamedMethod", testRenamedEndpointAndRenamedMethod),
        ("testRenamedEndpointAndReplaceAndDeleteMethod", testRenamedEndpointAndReplaceAndDeleteMethod),
        ("testRenamedEndpointAndRenameMethodAndReplaceAndDeleteParameterChange", testRenamedEndpointAndRenameMethodAndReplaceAndDeleteParameterChange)
        
    ]
}
