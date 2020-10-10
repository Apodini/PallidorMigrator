import XCTest
import PathKit
import SourceryFramework
@testable import PallidorMigrator

final class PallidorMigratorTests: XCTestCase {
    func testSemanticVersion() {
        let oldVersion = SemanticVersion(versionString: "1.0.1")
        let newVersion = SemanticVersion(versionString: "1.0.11")
        let newerVersion = SemanticVersion(versionString: "1.2.0")
        
        XCTAssertTrue(oldVersion < newVersion)
        XCTAssertTrue(oldVersion <= newVersion)
        XCTAssertTrue(newVersion >= oldVersion)
        XCTAssertTrue(newerVersion >= oldVersion)
        XCTAssertTrue(newVersion > oldVersion)
        XCTAssertFalse(newVersion >= newerVersion)
    }
    
    func testTypeIdentification() {
        let enumCode = try! FileParser(contents: "public enum Status : String, CaseIterable, Codable {}" ).parse()
        let enumType = WrappedTypes(types: enumCode.types)
        
        XCTAssertTrue(enumType.type == .enum)
        XCTAssertFalse(enumType.type == .class)
        
        let classCode = try! FileParser(contents: "public class Pet : Codable {}" ).parse()
        let classType = WrappedTypes(types: classCode.types)
        
        XCTAssertTrue(classType.type == .class)
        XCTAssertFalse(classType.type == .struct)
        
        let structCode = try! FileParser(contents: "public struct UserAPI : Codable {}" ).parse()
        let structType = WrappedTypes(types: structCode.types)
        
        XCTAssertTrue(structType.type == .struct)
        XCTAssertFalse(structType.type == .enum)
    }

    static var allTests = [
        ("testTypeIdentification", testTypeIdentification),
        ("testSemanticVersion", testSemanticVersion)
    ]
}
