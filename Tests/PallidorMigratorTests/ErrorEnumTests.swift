import XCTest
import SourceryFramework
@testable import PallidorMigrator

class ErrorEnumTests: XCTestCase {
    
    func testErrorEnumNoChange() {
        let migrationResult = getMigrationResult(migration: noChange, target: readResource(Resources.ErrorEnum.rawValue))
        let result = ErrorEnumTemplate().render(migrationResult)
        
        XCTAssertEqual(result, readResource(Resources.ResultErrorEnum.rawValue))
    }
    
    func testErrorEnumDeletedCase() {
        let enumDeletedCase = getMigrationResult(migration: noChange, target: readResource(Resources.ErrorEnumDeletedCase.rawValue)) as! WrappedEnum
        let enumFacade = getMigrationResult(migration: noChange, target: readResource(Resources.ResultErrorEnumDeletedCase.rawValue)) as! WrappedEnum
        
        let change = enumDeletedCase.compareCases(enumFacade)
        
        for c in change {
            enumFacade.modify(change: c)
        }
        
        let result = ErrorEnumTemplate().render(enumFacade)
        
        XCTAssertEqual(result, readResource(Resources.ResultErrorEnumDeletedCase.rawValue))
    }
    
    func testErrorEnumAddCase() {
        let enumDeletedCase = getMigrationResult(migration: noChange, target: readResource(Resources.ErrorEnumAddedCase.rawValue)) as! WrappedEnum
        let enumFacade = getMigrationResult(migration: noChange, target: readResource(Resources.ErrorEnumFacadeAddedCase.rawValue)) as! WrappedEnum
        
        let change = enumDeletedCase.compareCases(enumFacade)
        
        for c in change {
            enumFacade.modify(change: c)
        }
        
        let result = ErrorEnumTemplate().render(enumFacade)
        
        XCTAssertEqual(result, readResource(Resources.ResultErrorEnumAddedCase.rawValue))
    }
    
    enum Resources : String {
        case ErrorEnum, ErrorEnumAddedCase, ErrorEnumDeletedCase, ErrorEnumFacadeAddedCase, ErrorEnumFacadeDeletedCase
        case ResultErrorEnum, ResultErrorEnumAddedCase, ResultErrorEnumDeletedCase
    }
    
    static var allTests = [
        ("testErrorEnumDeletedCase", testErrorEnumDeletedCase),
        ("testErrorEnumNoChange", testErrorEnumNoChange)
    ]
    
}
