import XCTest

#if !canImport(ObjectiveC)
/// All tests for PallidorMigrator
/// - Returns: list of XCTestCaseEntry
public func allTests() -> [XCTestCaseEntry] {
    [
        testCase(PallidorMigratorTests.allTests),
        testCase(EnumTests.allTests),
        testCase(ModelTests.allTests),
        testCase(EndpointTests.allTests),
        testCase(EndpointIntegrationTests.allTests),
        testCase(ErrorEnumTests.allTests),
        testCase(MethodTests.allTests),
        testCase(MethodParameterTests.allTests),
        testCase(MethodIntegrationTests.allTests),
        testCase(ModelIntegrationTests.allTests),
        testCase(ModelPropertyTests.allTests),
        testCase(OfTypeModelTests.allTests)
    ]
}
#endif
