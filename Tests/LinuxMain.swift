import XCTest

import PallidorMigratorTests

var tests = [XCTestCaseEntry]()
tests += PallidorMigratorTests.allTests()
tests += EnumTests.allTests()
tests += ModelTests.allTests()
tests += EndpointTests.allTests()
tests += EndpointIntegrationTests.allTests()
tests += ErrorEnumTests.allTests()
tests += MethodIntegrationTests.allTests()
tests += MethodParameterTests.allTests()
tests += MethodTests.allTests()
tests += ModelIntegrationTests.allTests()
tests += ModelPropertyTests.allTests()
tests += OfTypeModelTests.allTests()

XCTMain(tests)
