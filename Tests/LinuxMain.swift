import XCTest

import PallidorMigratorTests

var tests = [XCTestCaseEntry]()
tests += PallidorMigratorTests.allTests()
tests += EnumTests.allTests()
tests += ModelTests.allTests()
tests += EndpointTests.allTests()
XCTMain(tests)
