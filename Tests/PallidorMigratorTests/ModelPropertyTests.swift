import XCTest
import SourceryFramework
@testable import PallidorMigrator

class ModelPropertyTests: XCTestCase {
    override func tearDown() {
        CodeStore.clear()
    }
    
    let addSinglePrimitivePropertyChange = """
   {
       "lang" : "Swift",
       "summary" : "Here would be a nice summary what changed between versions",
       "api-spec": "OpenAPI",
       "api-type": "REST",
       "from-version" : "0.0.1b",
       "to-version" : "0.0.2",
       "changes" : [
           {
               "reason": "Security issue related change",
               "object" : {
                   "name" : "Address"
               },
               "target" : "Property",
               "added" : [
                   {
                       "name" : "city",
                       "type" : "String",
                       "default-value" : "No city"
                   }
               ]
           }
       ]

   }
   """
    
    /// simulates that `city` property was added after initial facade generation
    func testAddedProperty() {
        let migrationResult = getMigrationResult(migration: addSinglePrimitivePropertyChange, target: readResource(Resources.ModelAddress.rawValue))
        let result = ModelTemplate().render(migrationResult)
        
        XCTAssertEqual(result, readResource(Resources.ResultModelAddressAddedSimpleProperty.rawValue))
    }
    
    let addSingleComplexPropertyChange = """
   {
       "lang" : "Swift",
       "summary" : "Here would be a nice summary what changed between versions",
       "api-spec": "OpenAPI",
       "api-type": "REST",
       "from-version" : "0.0.1b",
       "to-version" : "0.0.2",
       "changes" : [
           {
               "reason": "Security issue related change",
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
    
    /// simulates that `category` property was added after initial facade generation
    func testAddedComplexProperty() {
        let migrationResult = getMigrationResult(migration: addSingleComplexPropertyChange, target: readResource(Resources.ModelPet.rawValue))
        let result = ModelTemplate().render(migrationResult)
        
        XCTAssertEqual(result, readResource(Resources.ResultModelPetAddedComplexProperty.rawValue))
    }
    
    let deletePropertyChange = """
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
           }
       ]

   }
   """
    
    /// simulates a removed property `weight : String` from `Pet`
    /// - provides a fallback-value
    func testDeletedProperty() {
        let migrationResult = getMigrationResult(migration: deletePropertyChange, target: readResource(Resources.ModelPet.rawValue))
        let result = ModelTemplate().render(migrationResult)
        
        XCTAssertEqual(result, readResource(Resources.ResultModelPetDeletedProperty.rawValue))
    }
    
    let replacePropertyTypeChange = """
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
                   "name" : "Customer"
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
           }
       ]

   }
   """
    
    func testReplacedProperty() {
        let migrationResult = getMigrationResult(migration: replacePropertyTypeChange, target: readResource(Resources.ModelCustomerReplacedProperty.rawValue))
        let result = ModelTemplate().render(migrationResult)
        
        XCTAssertEqual(result, readResource(Resources.ResultModelCustomerReplacedProperty.rawValue))
    }
    
    let renamePropertyChange = """
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
               "original-id" : "tags",
               "renamed" : {
                   "id" : "tagsi"
               }
           },
           {
               "object" : {
                   "name" : "Category"
               },
               "target" : "Property",
               "original-id" : "name",
               "renamed" : {
                   "id" : "namenew"
               }
           }
       ]

   }
   """
    
    /// renames two properties from different models (`Pet` & `Category`)
    func testRenamedProperty() {
        let migrationResultPet = getMigrationResult(migration: renamePropertyChange, target: readResource(Resources.ModelPetRenamedProperty.rawValue))
        let resultPet = ModelTemplate().render(migrationResultPet)
        
        XCTAssertEqual(resultPet, readResource(Resources.ResultModelPetRenamedProperty.rawValue))
        
        let migrationResultCategory = getMigrationResult(migration: renamePropertyChange, target: readResource(Resources.ModelCategoryRenamedProperty.rawValue))
        let resultCategory = ModelTemplate().render(migrationResultCategory)
        
        XCTAssertEqual(resultCategory, readResource(Resources.ResultModelCategoryRenamedProperty.rawValue))
    }
    
    enum Resources: String {
        case ModelAddress, ModelPet, ModelCustomerReplacedProperty, ModelPetRenamedProperty, ModelCategoryRenamedProperty
        case ResultModelAddressAddedSimpleProperty, ResultModelPetAddedComplexProperty, ResultModelPetDeletedProperty, ResultModelCustomerReplacedProperty, ResultModelPetRenamedProperty, ResultModelCategoryRenamedProperty
    }
    
    static var allTests = [
        ("testAddedProperty", testAddedProperty),
        ("testAddedComplexProperty", testAddedComplexProperty),
        ("testDeletedProperty", testDeletedProperty),
        ("testReplacedProperty", testReplacedProperty),
        ("testRenamedProperty", testReplacedProperty)
    ]
}
