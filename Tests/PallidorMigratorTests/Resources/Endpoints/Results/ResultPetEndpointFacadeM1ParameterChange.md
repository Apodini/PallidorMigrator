import Foundation
import Combine
import JavaScriptCore

public struct PetAPI {
    static let decoder : JSONDecoder = NetworkManager.decoder

    public static func updatePet(name: String , petId: Int64 , status: String , authorization: HTTPAuthorization  = NetworkManager.authorization!, contentType: String?  = NetworkManager.defaultContentType) -> AnyPublisher<Pet, Error> {

return _PetAPI.updatePet(name: name, petId: petId, status: status, authorization: authorization, contentType: contentType)
.mapError({( OpenAPIError($0 as? _OpenAPIError)! )})
.map({Pet($0)!})
.receive(on: DispatchQueue.main)
.eraseToAnyPublisher()
}

public static func updatePetWithForm(element: Pet , authorization: HTTPAuthorization  = NetworkManager.authorization!, contentType: String?  = NetworkManager.defaultContentType) -> AnyPublisher<String, Error> {

return _PetAPI.updatePetWithForm(element: element.to()!, authorization: authorization, contentType: contentType)
.mapError({( OpenAPIError($0 as? _OpenAPIError)! )})
.receive(on: DispatchQueue.main)
.eraseToAnyPublisher()
}

public static func updatePetWithForm(petId: Int64 , name: String , status: String , authorization: HTTPAuthorization  = NetworkManager.authorization!, contentType: String?  = NetworkManager.defaultContentType) -> AnyPublisher<String, Error> {
struct InputParam : Codable {
    var petId : Int64
var name : String
var status : String
}

struct OutputParam : Codable {
    var element : Pet
}

let context = JSContext()!

context.evaluateScript("""
function conversion(input) { return JSON.stringify({ 'name': input.name, 'petId': input.petId } )}
""")

let inputEncoded = try! JSONEncoder().encode(InputParam(petId : petId, name : name, status : status))

let outputTmp = context
            .objectForKeyedSubscript("conversion")
            .call(withArguments: [inputEncoded])?.toString()

let outputDecoded = try! JSONDecoder().decode(OutputParam.self, from: outputTmp!.data(using: .utf8)!)
return PetAPI.updatePetWithForm(element : outputDecoded.element, authorization: authorization, contentType: contentType)
.mapError({( OpenAPIError($0 as? _OpenAPIError)! )})
.receive(on: DispatchQueue.main)
.eraseToAnyPublisher()
}

}
