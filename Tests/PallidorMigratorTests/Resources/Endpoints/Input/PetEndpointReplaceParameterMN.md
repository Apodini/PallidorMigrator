import Foundation
import Combine


struct _PetAPI {
    static let decoder : JSONDecoder = NetworkManager.decoder

/**
Update an existing pet by Id
RequestBody:
    - element Update an existent pet in the store
Responses:
    - 400: Invalid ID supplied
    - 405: Validation exception
    - 404: Pet not found
    - 200: Successful operation
*/
public static func updatePet(name: String, petId: Int64, status: String, authorization: HTTPAuthorization = NetworkManager.authorization!, contentType: String? = NetworkManager.defaultContentType) -> AnyPublisher<_Pet, Error> {
let path = NetworkManager.basePath! + "/pet"
    
    var path = NetworkManager.basePath! + "/pet/{petId}"
        path = path.replacingOccurrences(of: "{petId}", with: String(petId))
    path += "?name=\(name.description)&status=\(status.description)"

    return NetworkManager.putElement(authorization: authorization, on: URL(string: path)!, contentType: contentType)
.tryMap { data, response in
        guard let r = response as? HTTPURLResponse, 200..<299 ~= r.statusCode else {
        let httpResponse = response as! HTTPURLResponse

        if httpResponse.statusCode == 400 {
    throw _OpenAPIError.urlError(URLError(URLError.Code(rawValue: 400)))
}
if httpResponse.statusCode == 405 {
    throw _OpenAPIError.urlError(URLError(URLError.Code(rawValue: 405)))
}
if httpResponse.statusCode == 404 {
    throw _OpenAPIError.urlError(URLError(URLError.Code(rawValue: 404)))
}

            throw _OpenAPIError.urlError(URLError(URLError.Code(rawValue: httpResponse.statusCode)))
        }
        return data
}
.decode(type: _Pet.self, decoder: decoder)
    .receive(on: DispatchQueue.main)
    .eraseToAnyPublisher()
}

/**


Responses:
    - 405: Invalid input
*/
public static func updatePetWithForm(element: _Pet, authorization: HTTPAuthorization = NetworkManager.authorization!, contentType: String? = NetworkManager.defaultContentType) -> AnyPublisher<String, Error> {
let path = NetworkManager.basePath! + "/pet/{petId}"

    return NetworkManager.postElement(element: element, authorization: authorization, on: URL(string: path)!, contentType: contentType)
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
