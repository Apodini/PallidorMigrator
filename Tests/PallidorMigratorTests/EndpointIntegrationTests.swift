import XCTest
import SourceryFramework
@testable import PallidorMigrator

class EndpointIntegrationTests: XCTestCase {
    
    override func tearDown() {
        CodeStore.clear()
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

    enum Resources: String {
        case PetEndpointRenamedAndReplacedMethod, PetEndpointFacadeReplacedMethod
        case ResultPetEndpointFacadeRenamedAndReplacedMethod
    }
    
    static var allTests = [
        ("testRenamedEndpointAndReplaceMethod", testRenamedEndpointAndReplaceMethod)
    ]
}
