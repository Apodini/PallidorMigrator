import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(PallidorMigratorTests.allTests),
        testCase(EnumTests.allTests),
        testCase(ModelTests.allTests),
        testCase(EndpointTests.allTests)
    ]
}
#endif
