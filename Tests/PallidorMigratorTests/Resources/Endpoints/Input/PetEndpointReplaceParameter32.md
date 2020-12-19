import Foundation
import Combine


struct _PetAPI {
    static let decoder : JSONDecoder = NetworkManager.decoder

/**


Responses:
    - 405: Invalid input
*/
public static func updatePetWithForm(name: String, petAndStatus: _PetAndStatus, authorization: HTTPAuthorization = NetworkManager.authorization!, contentType: String? = NetworkManager.defaultContentType) -> AnyPublisher<String, Error> {
let path = NetworkManager.basePath! + "/pet"

    return NetworkManager.postElement(name: name, petAndStatus: PetAndStatus, authorization: authorization, on: URL(string: path)!, contentType: contentType)
.tryMap { data, response in
        guard let r = response as? HTTPURLResponse, 200..<299 ~= r.statusCode else {
        let httpResponse = response as! HTTPURLResponse

        if httpResponse.statusCode == 405 {
    throw _OpenAPIError.urlError(URLError(URLError.Code(rawValue: 405)))
}

            throw _OpenAPIError.urlError(URLError(URLError.Code(rawValue: httpResponse.statusCode)))
        }
        return String(data: data, encoding: .utf8)!
}
    .receive(on: DispatchQueue.main)
    .eraseToAnyPublisher()
}

}
