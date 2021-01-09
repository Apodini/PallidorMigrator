// Identifier_name linting rule is disabled
// because enum cases reflect the names of corresponding test files
// Force try is disabled for lines that refer to fetching and parsing
// source code with Sourcery.
// swiftlint:disable identifier_name
import XCTest
import SourceryFramework
@testable import PallidorMigrator

class ErrorEnumTests: XCTestCase {
    func testErrorEnumNoChange() {
        let migrationResult = getMigrationResult(
            migration: noChange,
            target: readResource(Resources.ErrorEnum.rawValue))
        let result = ErrorEnumTemplate().render(migrationResult)
        
        XCTAssertEqual(result, readResource(Resources.ResultErrorEnum.rawValue))
    }
    
    func testErrorEnumDeletedCase() {
        guard let enumDeletedCase = getMigrationResult(
                migration: noChange,
                target: readResource(Resources
                                        .ErrorEnumDeletedCase
                                        .rawValue)
        ) as? WrappedEnum else {
            fatalError("Migration failed.")
        }

        guard let enumFacade = getMigrationResult(
                migration: noChange,
                target: readResource(Resources
                                        .ResultErrorEnumDeletedCase
                                        .rawValue)
        ) as? WrappedEnum else {
            fatalError("Migration failed.")
        }
        
        let changes = enumDeletedCase.compareCases(enumFacade)
        
        for change in changes {
            enumFacade.modify(change: change)
        }
        
        let result = ErrorEnumTemplate().render(enumFacade)
        
        XCTAssertEqual(result, readResource(Resources.ResultErrorEnumDeletedCase.rawValue))
    }
    
    func testErrorEnumAddCase() {
        guard let enumAddedCases = getMigrationResult(
                migration: noChange,
                target: readResource(Resources
                                        .ErrorEnumAddedCase
                                        .rawValue)
        ) as? WrappedEnum else {
            fatalError("Migration failed.")
        }

        guard let enumFacade = getMigrationResult(
                migration: noChange,
                target: readResource(Resources
                                        .ErrorEnumFacadeAddedCase
                                        .rawValue)
        ) as? WrappedEnum else {
            fatalError("Migration failed.")
        }
        
        let changes = enumAddedCases.compareCases(enumFacade)
        
        for change in changes {
            enumFacade.modify(change: change)
        }
        
        let result = ErrorEnumTemplate().render(enumFacade)
        
        XCTAssertEqual(result, readResource(Resources.ResultErrorEnumAddedCase.rawValue))
    }
    
    enum Resources: String {
        case ErrorEnum, ErrorEnumAddedCase, ErrorEnumDeletedCase, ErrorEnumFacadeAddedCase, ErrorEnumFacadeDeletedCase
        case ResultErrorEnum, ResultErrorEnumAddedCase, ResultErrorEnumDeletedCase
    }
    
    static var allTests = [
        ("testErrorEnumDeletedCase", testErrorEnumDeletedCase),
        ("testErrorEnumNoChange", testErrorEnumNoChange),
        ("testErrorEnumAddCase", testErrorEnumAddCase)
    ]
}
