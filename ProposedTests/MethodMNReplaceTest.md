#  Replacing M methods with N methods
Currently, Pallidor is a able to replace one method with another one. In some scenarios, a method is replaced by combining the results of two or more methods. Furthermore, the results of multiple method are replaced by the result of a single method. This document serves as a reference of the desired outcome and proposes a unit test that validates its functionality.

## Replacing one method with multiple methods

Migration guide that indicates that a method was replaced by multiple methods. The convert and revert code specifies the processing of the results:

```
{
    "summary" : "Here would be a nice summary what changed between versions",
    "api-spec": "OpenAPI",
    "api-type": "REST",
    "from-version" : "0.0.1b",
    "to-version" : "0.0.2",
    "changes" : [
        {
            "object":{
               "operation-id":"updatePetName",
               "defined-in":"/pet"
            },
            "target" : "Signature",
            "replacement-id" : "updatePetName",
            "replaced" : {
               "operation-id":"updatePet",
               "defined-in":"/pet"
             }
        },
        {
            "object":{
               "operation-id":"updatePetType",
               "defined-in":"/pet"
            },
            "target" : "Signature",
            "replacement-id" : "updatePetType",
            "custom-convert" : "function conversion(pet) { return JSON.stringify({ 'name': pet.name, 'type': pet.type } )}",
            "custom-revert" : "function conversion(name, type) { return JSON.stringify({ 'name' : name, 'type': type } )}",
            "replaced" : {
               "operation-id":"updatePet",
               "defined-in":"/pet"
             }
        }
    ]

}

```
Updating a `Pet` is replaced by two separate methods that each perform an update on certain properties of a `Pet`.
The `custom-convert` code is used to split the `Pet` parameter of the `updatePet` method into the parameters that are required by its replacement methods.
The `custom-revert` code is used to combine the return values of the replacement methods into the `Pet` return value of the `updatePet` method. Both functions are only specified at the **last** replacement change. The **1N** replacements must be detected by Pallidor and handled accordingly.

After successfully migrating the facade code according to the changes in the migration guide, the `updatePet` method should call the replacement methods with their respective parameters and combine their results before returning the `Pet` result to the callee.

```
public static func updatePet(element: Pet , authorization: HTTPAuthorization  = NetworkManager.authorization!, contentType: String?  = NetworkManager.defaultContentType) -> AnyPublisher<Pet, Error> {
struct InputParam : Codable {
    var element : Pet
}

struct OutputParam : Codable {
    var name : String
    var type : PetType
}

let context = JSContext()!

context.evaluateScript("""
function conversion(pet) { return JSON.stringify({ 'name': pet.name, 'type': pet.type } )}
""")

let inputEncoded = try! JSONEncoder().encode(InputParam(element: element))

let outputTmp = context.objectForKeyedSubscript("conversion").call(withArguments: [inputEncoded])?.toString()

let outputDecoded = try! JSONDecoder().decode(OutputParam.self, from: outputTmp!.data(using: .utf8)!)

// requires combination of both methods
// no solution yet
return (_PetAPI.updatePetName(name: outputDecoded.name, ... ) + _PetAPI.updatePetType( type: outputDecoded.type, ...))
.mapError({( OpenAPIError($0 as? _OpenAPIError)! )})
// the result here must be of a object type to store all results of the replacement methods.
// 
// struct CombinedResult : Codable {
//  var name : String
//  var type : PetType
// }
//
.map({ (result) -> Pet in
    let context = JSContext()!
    let encoded = try! JSONEncoder().encode(result)
    context.evaluateScript("""
    function conversion(name, type) { return JSON.stringify({ 'name' : name, 'type': type } )}
""")
    let encString = context.objectForKeyedSubscript("conversion").call(withArguments: [String(data: encoded.name, encoding: .utf8)!, String(data: encoded.type, encoding: .utf8)!])?.toString()
    return Pet(try! JSONDecoder().decode(_Pet.self, from: encString!.data(using: .utf8)!))!
})
.receive(on: DispatchQueue.main)
.eraseToAnyPublisher()
}
```

## Replacing multiple methods with one method

Migration guide that indicates that two methods were replaced by one method. The convert and revert code specifies the processing of the results:

```
{
    "summary" : "Here would be a nice summary what changed between versions",
    "api-spec": "OpenAPI",
    "api-type": "REST",
    "from-version" : "0.0.1b",
    "to-version" : "0.0.2",
    "changes" : [
        {
            "object":{
               "operation-id":"updatePet",
               "defined-in":"/pet"
            },
            "target" : "Signature",
            "replacement-id" : "updatePet",
            "custom-convert" : "function conversion(name, type) { return JSON.stringify({ 'element' : { 'name': name, 'type': type } } )}",
            "custom-revert" : "function conversion(pet) { return pet.id )}",
            "replaced" : {
               "operation-id":"updatePetType",
               "defined-in":"/pet"
             }
        },
        {
            "object":{
               "operation-id":"updatePet",
               "defined-in":"/pet"
            },
            "target" : "Signature",
            "replacement-id" : "updatePet",
            "custom-convert" : "function conversion(name, type) { return JSON.stringify({ 'element' : { 'name': name, 'type': type } } )}",
            "custom-revert" : "function conversion(pet) { return JSON.stringify({ 'name': pet.name } )}",
            "replaced" : {
               "operation-id":"updatePetName",
               "defined-in":"/pet"
             }
        }
    ]

}

```
Updating a `Pet` replaces two separate methods that each perform an update on certain properties of a `Pet`.
The `custom-convert` code is used to merge the parameters of both replaced methods to the `Pet` parameter of the `updatePet` method.
The `custom-revert` code is used to split the return value of the `updatePet` method into the return values of the replaced methods. Both replaced methods specify the same `custom-convert` functionality but differ in the `custom-revert` functionality. Pallidor must detect the type of replace change (**M1**) and migrate the facade code accordingly.

After successfully migrating the facade code the replaced methods should call the `updatePet` method with its `Pet` parameter and return their previous result to the callee.

```
public static func updatePetName(name: String , authorization: HTTPAuthorization  = NetworkManager.authorization!, contentType: String?  = NetworkManager.defaultContentType) -> AnyPublisher<Pet, Error> {
struct InputParam : Codable {
    var name : String
    // type is unknown here - default value is used
    var type = PetType.default
}

struct OutputParam : Codable {
    var element: Pet
}

let context = JSContext()!

context.evaluateScript("""
function conversion(name, type) { return JSON.stringify({ 'element' : { 'name': name, 'type': type } } )}
""")

let inputEncoded = try! JSONEncoder().encode(InputParam(name: name))

let outputTmp = context.objectForKeyedSubscript("conversion").call(withArguments: [inputEncoded])?.toString()

let outputDecoded = try! JSONDecoder().decode(OutputParam.self, from: outputTmp!.data(using: .utf8)!)

return _PetAPI.updatePet(element: outputDecoded.element, ... )
.mapError({( OpenAPIError($0 as? _OpenAPIError)! )})
// the result here is of the Pet type from updatePet
.map({ (result) -> String in
    let context = JSContext()!
    let encoded = try! JSONEncoder().encode(result)
    context.evaluateScript("""
    function conversion(pet) { return pet.name )}
""")
    let encString = context.objectForKeyedSubscript("conversion").call(withArguments: [String(data: encoded, encoding: .utf8)!])?.toString()
    // return String type
    return encString!
})
.receive(on: DispatchQueue.main)
.eraseToAnyPublisher()
}


/// updatePetType returns the ID of a pet
public static func updatePetType(type: PetType , authorization: HTTPAuthorization  = NetworkManager.authorization!, contentType: String?  = NetworkManager.defaultContentType) -> AnyPublisher<Int32, Error> {
struct InputParam : Codable {
    // name is unknown here - default value of "" is used
    var name = ""
    var type : PetType
}

struct OutputParam : Codable {
    var element: Pet
}

let context = JSContext()!

context.evaluateScript("""
function conversion(name, type) { return JSON.stringify({ 'element' : { 'name': name, 'type': type } } )}
""")

let inputEncoded = try! JSONEncoder().encode(InputParam(type: type))

let outputTmp = context.objectForKeyedSubscript("conversion").call(withArguments: [inputEncoded])?.toString()

let outputDecoded = try! JSONDecoder().decode(OutputParam.self, from: outputTmp!.data(using: .utf8)!)

return _PetAPI.updatePet(element: outputDecoded.element, ... )
.mapError({( OpenAPIError($0 as? _OpenAPIError)! )})
// the result here is of the Pet type from updatePet
.map({ (result) -> Int32 in
    let context = JSContext()!
    let encoded = try! JSONEncoder().encode(result)
    context.evaluateScript("""
    function conversion(pet) { return pet.id )}
""")
    let encString = context.objectForKeyedSubscript("conversion").call(withArguments: [String(data: encoded, encoding: .utf8)!])?.toString()
    // return Int32 type
    return Int32(encString!)!
})
.receive(on: DispatchQueue.main)
.eraseToAnyPublisher()
}
```
