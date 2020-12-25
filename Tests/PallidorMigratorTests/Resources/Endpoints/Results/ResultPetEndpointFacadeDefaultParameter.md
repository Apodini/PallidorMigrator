import Foundation
import Combine
import JavaScriptCore

public struct PetAPI {
    static let decoder : JSONDecoder = NetworkManager.decoder

    public static func findPetsByStatus(status: String?  = "available", authorization: HTTPAuthorization  = NetworkManager.authorization!, contentType: String?  = NetworkManager.defaultContentType) -> AnyPublisher<[Pet], Error> {
let context = JSContext()!

return _PetAPI.findPetsByStatus(status: status, authorization: authorization, contentType: contentType)
.mapError({( OpenAPIError($0 as? _OpenAPIError)! )})
.map({$0.map({Pet($0)!})})
.receive(on: DispatchQueue.main)
.eraseToAnyPublisher()
}

}
