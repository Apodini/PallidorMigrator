import XCTest
import SourceryFramework
@testable import PallidorMigrator

class OfTypeModelTests: XCTestCase {
    override func tearDown() {
        CodeStore.clear()
    }
    
    func testOfTypeModelNoChange() {
        let migrationResult = getMigrationResult(migration: noChange, target: readResource(Resources.ModelOfType.rawValue))
        let result = ModelTemplate().render(migrationResult)

        XCTAssertEqual(result, readResource(Resources.ResultModelOfType.rawValue))
    }
    
    let renameOfTypeModelChange = """
   {
       "summary" : "Here would be a nice summary what changed between versions",
       "api-spec": "OpenAPI",
       "api-type": "REST",
       "from-version" : "0.0.1b",
       "to-version" : "0.0.2",
       "changes" : [
           {
               "object" : {
                   "name" : "PayInstallSched"
               },
               "target" : "Signature",
               "original-id" : "PaymentInstallmentSchedule"
           }
       ]
   }
   """
    
    func testOfTypeModelRenamed() {
        let migrationResult = getMigrationResult(migration: renameOfTypeModelChange, target: readResource(Resources.ModelOfTypeRenamed.rawValue))
        let result = ModelTemplate().render(migrationResult)

        XCTAssertEqual(result, readResource(Resources.ResultModelOfTypeRenamed.rawValue))
    }
    
    let deleteOfTypeEnumCaseChange = """
   {
       "summary" : "Here would be a nice summary what changed between versions",
       "api-spec": "OpenAPI",
       "api-type": "REST",
       "from-version" : "0.0.1b",
       "to-version" : "0.0.2",
       "changes" : [
           {
               "object" : {
                   "name" : "PaymentInstallmentSchedule"
               },
               "target" : "Case",
               "fallback-value" : {
                    "id" : "PsdInstallmentSchedule"
                }
           }
       ]

   }
   """
    
    func testOfTypeModelDeletedCase() {
        let migrationResult = getMigrationResult(migration: deleteOfTypeEnumCaseChange, target: readResource(Resources.ModelOfTypeFacade.rawValue))
        let result = ModelTemplate().render(migrationResult)

        XCTAssertEqual(result, readResource(Resources.ResultModelOfTypeDeletedCase.rawValue))
    }
    
    let deleteOfTypeChange = """
   {
       "summary" : "Here would be a nice summary what changed between versions",
       "api-spec": "OpenAPI",
       "api-type": "REST",
       "from-version" : "0.0.1b",
       "to-version" : "0.0.2",
       "changes" : [
           {
               "object" : {
                   "name" : "PaymentInstallmentSchedule"
               },
               "target" : "Signature",
               "fallback-value" : {
                    "id" : "PaymentInstallmentSchedule"
                }
           }
       ]

   }
   """
    
    func testOfTypeModelDeleted() {
        let fp = try! FileParser(contents: readResource(Resources.ModelOfTypeFacade.rawValue))
        let code = try! fp.parse()
        let types = WrappedTypes(types: code.types)
        let facade = types.getModifiable()!
        
        CodeStore.initInstance(previous: [facade], current: [])
    
        _ = getMigrationResult(migration: deleteOfTypeChange, target: readResource(Resources.ModelPlaceholder.rawValue))
        
        let migrationResult = CodeStore.getInstance().getModel(facade.id)!
        let result = ModelTemplate().render(migrationResult)

        XCTAssertEqual(result, readResource(Resources.ResultModelOfTypeDeleted.rawValue))
    }
    
    let replaceOfTypeModelChange = """
   {
       "summary" : "Here would be a nice summary what changed between versions",
       "api-spec": "OpenAPI",
       "api-type": "REST",
       "from-version" : "0.0.1b",
       "to-version" : "0.0.2",
       "changes" : [
           {
               "object" : {
                   "name" : "PaymentInstallmentSchedule"
               },
               "target" : "Signature",
               "replacement-id" : "PsiInstallmentSchedule",
               "custom-convert" : "function conversion(o) { return JSON.stringify({ 'type' : 'PSI' } )}",
               "custom-revert" : "function conversion(o) { return JSON.stringify({ 'type': '', 'of' : { 'type': 'PSI'} } )}",
           }
       ]

   }
   """
    
    func testOfTypeModelReplaced() {
        let migrationResult = getMigrationResult(migration: replaceOfTypeModelChange, target: readResource(Resources.ModelOfTypeFacade.rawValue))
        let result = ModelTemplate().render(migrationResult)

        XCTAssertEqual(result, readResource(Resources.ResultModelOfTypeReplaced.rawValue))
    }
    
    enum Resources: String {
        case ModelOfType, ModelOfTypeRenamed, ModelOfTypeFacade, ModelPlaceholder
        case ResultModelOfType, ResultModelOfTypeRenamed, ResultModelOfTypeDeletedCase, ResultModelOfTypeDeleted, ResultModelOfTypeReplaced
    }
    
    static var allTests = [
        ("testOfTypeModelNoChange", testOfTypeModelNoChange),
        ("testOfTypeModelRenamed", testOfTypeModelRenamed),
        ("testOfTypeModelDeletedCase", testOfTypeModelDeletedCase),
        ("testOfTypeModelDeleted", testOfTypeModelDeleted),
        ("testOfTypeModelReplaced", testOfTypeModelReplaced)
    ]
}
