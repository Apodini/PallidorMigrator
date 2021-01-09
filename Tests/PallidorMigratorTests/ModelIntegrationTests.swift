// Identifier_name linting rule is disabled
// because enum cases reflect the names of corresponding test files
// Force try is disabled for lines that refer to fetching and parsing
// source code with Sourcery. 
// Line length exceeds due to convert/revert definition in migration guide
// swiftlint:disable identifier_name line_length
import XCTest
import SourceryFramework
@testable import PallidorMigrator

class ModelIntegrationTests: XCTestCase {
    override func tearDown() {
        CodeStore.clear()
        super.tearDown()
    }
    
    let deletedAndAddedProperty = """
    {
        "summary" : "Here would be a nice summary what changed between versions",
        "api-spec": "OpenAPI",
        "api-type": "REST",
        "from-version" : "0.0.1b",
        "to-version" : "0.0.2",
        "changes" : [
            {
                "object" : {
                    "name" : "Pet"
                },
                "target" : "Property",
                "fallback-value" : {
                    "name" : "weight",
                    "type" : "String",
                    "default-value" : "fat"
                }
            },
           {
               "object" : {
                   "name" : "Pet"
               },
               "target" : "Property",
               "added" : [
                   {
                       "name" : "category",
                       "type" : "Category",
                       "default-value" : "{ 'id' : 42, 'name' : 'SuperPet' }"
                   }
               ]
           }
        ]

    }
    """
    
    func testDeletedAndAddedProperty() {
        let migrationResult = getMigrationResult(
            migration: deletedAndAddedProperty,
            target: readResource(Resources.ModelPet.rawValue))
        let result = ModelTemplate().render(migrationResult)
        
        XCTAssertEqual(result, readResource(Resources.ResultModelPetAddedAndDeletedProperty.rawValue))
    }
    
    let renameModelAndAddPropertyChange = """
    {
        "summary" : "Here would be a nice summary what changed between versions",
        "api-spec": "OpenAPI",
        "api-type": "REST",
        "from-version" : "0.0.1b",
        "to-version" : "0.0.2",
        "changes" : [
           {
               "object" : {
                   "name" : "MyPet"
               },
               "target" : "Property",
               "added" : [
                   {
                       "name" : "category",
                       "type" : "Category",
                       "default-value" : "{ 'id' : 42, 'name' : 'SuperPet' }"
                   }
               ]
           },
           {
               "object" : {
                   "name" : "MyPet"
               },
               "target" : "Signature",
               "original-id" : "Pet"
           }
        ]

    }
    """
    
    func testRenamedModelAndAddProperty() {
        let migrationResult = getMigrationResult(
            migration: renameModelAndAddPropertyChange,
            target: readResource(Resources.ModelPetRenamedAndAddedProperty.rawValue)
        )
        let result = ModelTemplate().render(migrationResult)

        XCTAssertEqual(result, readResource(Resources.ResultModelPetRenamedAndAddedProperty.rawValue))
    }
    
    let renameModelAndReplacePropertyChange = """
   {
       "summary" : "Here would be a nice summary what changed between versions",
       "api-spec": "OpenAPI",
       "api-type": "REST",
       "from-version" : "0.0.1b",
       "to-version" : "0.0.2",
       "changes" : [
           {
               "object" : {
                   "name" : "NewCustomer"
               },
               "target" : "Property",
               "replacement-id" : "addresses",
               "type" : "[NewAddress]",
               "custom-convert" : "function conversion(address) { return { 'city' : address.city, 'street' : address.street, 'universe' : '42' } }",
               "custom-revert" : "function conversion(address) { return address.universe == '42' ? { 'city' : address.city, 'street' : address.street, 'zip': '81543', 'state' : 'Bavaria' } : { 'city' : address.city, 'street' : address.street , 'zip' : '80634', 'state' : 'Bavaria' } }",
               "replaced" : {
                       "name" : "address",
                       "type" : "[Address]"
               }
           },
           {
               "object" : {
                   "name" : "NewCustomer"
               },
               "target" : "Signature",
               "original-id" : "Customer"
           }
       ]
   }
   """

    func testRenamedModelAndReplacedProperty() {
        let migrationResult = getMigrationResult(
            migration: renameModelAndReplacePropertyChange,
            target: readResource(Resources.ModelCustomerRenamedAndReplacedProperty.rawValue)
        )
        let result = ModelTemplate().render(migrationResult)

        XCTAssertEqual(result, readResource(Resources
                                                .ResultModelCustomerRenamedAndReplacedProperty
                                                .rawValue))
    }
    
    let renameModelAndDeletePropertyChange = """
   {
       "summary" : "Here would be a nice summary what changed between versions",
       "api-spec": "OpenAPI",
       "api-type": "REST",
       "from-version" : "0.0.1b",
       "to-version" : "0.0.2",
       "changes" : [
          {
              "object" : {
                  "name" : "NewCustomer"
              },
              "target" : "Property",
              "fallback-value" : {
                  "name" : "addresses",
                  "type" : "[NewAddresses]",
                  "default-value" : "[{'name' : 'myaddress'}]"
              }
          },
           {
               "object" : {
                   "name" : "NewCustomer"
               },
               "target" : "Signature",
               "original-id" : "Customer"
           }
       ]
   }
   """

    func testRenamedModelAndDeletedProperty() {
        let migrationResult = getMigrationResult(
            migration: renameModelAndDeletePropertyChange,
            target: readResource(Resources.ModelCustomerRenamedAndDeletedProperty.rawValue)
        )
        let result = ModelTemplate().render(migrationResult)

        XCTAssertEqual(result, readResource(Resources
                                                .ResultModelCustomerRenamedAndDeletedProperty
                                                .rawValue))
    }
    
    let renameModelAndRenamedPropertyChange = """
   {
       "summary" : "Here would be a nice summary what changed between versions",
       "api-spec": "OpenAPI",
       "api-type": "REST",
       "from-version" : "0.0.1b",
       "to-version" : "0.0.2",
       "changes" : [
             {
                 "object" : {
                     "name" : "NewCategory"
                 },
                 "target" : "Property",
                 "original-id" : "name",
                 "renamed" : {
                     "id" : "namenew"
                 }
             },
           {
               "object" : {
                   "name" : "NewCategory"
               },
               "target" : "Signature",
               "original-id" : "Category"
           }
       ]
   }
   """

    func testRenamedModelAndRenamedProperty() {
        let migrationResult = getMigrationResult(
            migration: renameModelAndRenamedPropertyChange,
            target: readResource(Resources.ModelCategoryRenamedAndPropertyRenamed.rawValue)
        )
        let result = ModelTemplate().render(migrationResult)

        XCTAssertEqual(result, readResource(Resources
                                                .ResultModelCategoryRenamedAndRenamedProperty
                                                .rawValue))
    }
    
    enum Resources: String {
        case ModelPet, ModelCustomerRenamedAndReplacedProperty, ModelCustomerRenamedAndDeletedProperty, ModelCategoryRenamedAndPropertyRenamed, ModelPetRenamedAndAddedProperty
        case ResultModelPetAddedAndDeletedProperty, ResultModelCustomerRenamedAndReplacedProperty, ResultModelCustomerRenamedAndDeletedProperty, ResultModelCategoryRenamedAndRenamedProperty, ResultModelPetRenamedAndAddedProperty
    }
    
    static var allTests = [
        ("testRenamedModelAndDeletedProperty", testRenamedModelAndDeletedProperty),
        ("testRenamedModelAndReplacedProperty", testRenamedModelAndReplacedProperty),
        ("testDeletedAndAddedProperty", testDeletedAndAddedProperty),
        ("testRenamedModelAndRenamedProperty", testRenamedModelAndRenamedProperty)
    ]
}
