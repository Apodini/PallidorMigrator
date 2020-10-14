import XCTest
import SourceryFramework
@testable import PallidorMigrator

class ModelIntegrationTests: XCTestCase {
    override func tearDown() {
        CodeStore.clear()
    }
    
    let deletedAndAddedProperty = """
    {
        "lang" : "Swift",
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
        let migrationResult = getMigrationResult(migration: deletedAndAddedProperty, target: readResource(Resources.ModelPet.rawValue))
        let result = ModelTemplate().render(migrationResult)
        
        XCTAssertEqual(result, readResource(Resources.ResultModelPetAddedAndDeletedProperty.rawValue))
    }
    
    let renameModelAndReplacePropertyChange = """
   {
       "lang" : "Swift",
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
        let migrationResult = getMigrationResult(migration: renameModelAndReplacePropertyChange, target: readResource(Resources.ModelCustomerRenamedAndReplacedProperty.rawValue))
        let result = ModelTemplate().render(migrationResult)

        XCTAssertEqual(result, readResource(Resources.ResultModelCustomerRenamedAndReplacedProperty.rawValue))
    }
    
    let renameModelAndDeletePropertyChange = """
   {
       "lang" : "Swift",
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
        let migrationResult = getMigrationResult(migration: renameModelAndDeletePropertyChange, target: readResource(Resources.ModelCustomerRenamedAndDeletedProperty.rawValue))
        let result = ModelTemplate().render(migrationResult)

        XCTAssertEqual(result, readResource(Resources.ResultModelCustomerRenamedAndDeletedProperty.rawValue))
    }
    
    enum Resources: String {
        case ModelPet, ModelCustomerRenamedAndReplacedProperty, ModelCustomerRenamedAndDeletedProperty
        case ResultModelPetAddedAndDeletedProperty, ResultModelCustomerRenamedAndReplacedProperty, ResultModelCustomerRenamedAndDeletedProperty
    }
    
    static var allTests = [
        ("testRenamedModelAndDeletedProperty", testRenamedModelAndDeletedProperty),
        ("testRenamedModelAndReplacedProperty", testRenamedModelAndReplacedProperty),
        ("testDeletedAndAddedProperty", testDeletedAndAddedProperty)
    ]
}