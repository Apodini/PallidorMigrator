import Foundation
import Combine
import JavaScriptCore

public struct PetAPI {
    static let decoder : JSONDecoder = NetworkManager.decoder

    public static func updatePetWithForm(name: String , petAndStatus: PetAndStatus , authorization: HTTPAuthorization  = NetworkManager.authorization!, contentType: String?  = NetworkManager.defaultContentType) -> AnyPublisher<String, Error> {

return _PetAPI.updatePetWithForm(name: name, petAndStatus: petAndStatus, authorization: authorization, contentType: contentType)
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
    var name : String
var petAndStatus : PetAndStatus
}

let context = JSContext()!

context.evaluateScript("""
function conversion(input) { return JSON.stringify({ 'name': input.name, 'petAndStatus': { 'petId': input.petId, 'status': input.status }} )}
""")

let inputEncoded = try! JSONEncoder().encode(InputParam(petId : petId, name : name, status : status))

let outputTmp = context.objectForKeyedSubscript("conversion").call(withArguments: [inputEncoded])?.toString()

let outputDecoded = try! JSONDecoder().decode(OutputParam.self, from: outputTmp!.data(using: .utf8)!)
return PetAPI.updatePetWithForm(name : outputDecoded.name, petAndStatus : outputDecoded.petAndStatus, authorization: authorization, contentType: contentType)
.mapError({( OpenAPIError($0 as? _OpenAPIError)! )})
.receive(on: DispatchQueue.main)
.eraseToAnyPublisher()
}

}
