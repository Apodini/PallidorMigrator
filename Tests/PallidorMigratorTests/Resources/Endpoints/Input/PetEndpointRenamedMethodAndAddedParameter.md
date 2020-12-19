import Foundation
import Combine


struct _PetAPI {
    static let decoder : JSONDecoder = NetworkManager.decoder

/**
Add a new pet to the store
RequestBody:
    - element Create a new pet in the store
Responses:
    - 200: Successful operation
    - 405: Invalid input
*/
public static func addMyPet(status: String?, element: _Pet, authorization: HTTPAuthorization = NetworkManager.authorization!, contentType: String? = NetworkManager.defaultContentType) -> AnyPublisher<_Pet, Error> {
var path = NetworkManager.basePath! + "/pet"
    
    path += "?\(status != nil ? "&status=\(status?.description ?? "")" : "")"

    return NetworkManager.postElement(element, authorization: authorization, on: URL(string: path)!, contentType: contentType)
.tryMap { data, response in
        guard let r = response as? HTTPURLResponse, 200..<299 ~= r.statusCode else {
        let httpResponse = response as! HTTPURLResponse

        if httpResponse.statusCode == 405 {
    throw _OpenAPIError.urlError(URLError(URLError.Code(rawValue: 405)))
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
    - 400: Invalid pet value
*/
public static func deletePet(api_key: String?, petId: Int64, authorization: HTTPAuthorization = NetworkManager.authorization!, contentType: String? = NetworkManager.defaultContentType) -> AnyPublisher<String, Error> {
var path = NetworkManager.basePath! + "/pet/{petId}"
    path = path.replacingOccurrences(of: "{petId}", with: String(petId))

var customHeaders = [String : String]()
customHeaders["api_key"] = api_key?.description ?? ""
    return NetworkManager.delete(at: URL(string: path)!, authorization: authorization, contentType: contentType, headers: customHeaders)
.tryMap { data, response in
        guard let r = response as? HTTPURLResponse, 200..<299 ~= r.statusCode else {
        let httpResponse = response as! HTTPURLResponse

        if httpResponse.statusCode == 400 {
    throw _OpenAPIError.urlError(URLError(URLError.Code(rawValue: 400)))
}

            throw _OpenAPIError.urlError(URLError(URLError.Code(rawValue: httpResponse.statusCode)))
        }
        return String(data: data, encoding: .utf8)!
}
    .receive(on: DispatchQueue.main)
    .eraseToAnyPublisher()
}

/**
Multiple status values can be provided with comma separated strings

Responses:
    - 400: Invalid status value
    - 200: successful operation
*/
public static func findPetsByStatus(status: String?, authorization: HTTPAuthorization = NetworkManager.authorization!, contentType: String? = NetworkManager.defaultContentType) -> AnyPublisher<[_Pet], Error> {
var path = NetworkManager.basePath! + "/pet/findByStatus"
    
path += "?\(status != nil ? "&status=\(status?.description ?? "")" : "")"

    return NetworkManager.getElement(on: URL(string: path)!, authorization: authorization, contentType: contentType)
.tryMap { data, response in
        guard let r = response as? HTTPURLResponse, 200..<299 ~= r.statusCode else {
        let httpResponse = response as! HTTPURLResponse

        if httpResponse.statusCode == 400 {
    throw _OpenAPIError.urlError(URLError(URLError.Code(rawValue: 400)))
}

            throw _OpenAPIError.urlError(URLError(URLError.Code(rawValue: httpResponse.statusCode)))
        }
        return data
}
.decode(type: [_Pet].self, decoder: decoder)
    .receive(on: DispatchQueue.main)
    .eraseToAnyPublisher()
}

/**
Multiple tags can be provided with comma separated strings. Use tag1, tag2, tag3 for testing.

Responses:
    - 400: Invalid tag value
    - 200: successful operation
*/
public static func findPetsByTags(tags: [String]?, authorization: HTTPAuthorization = NetworkManager.authorization!, contentType: String? = NetworkManager.defaultContentType) -> AnyPublisher<[_Pet], Error> {
var path = NetworkManager.basePath! + "/pet/findByTags"
    
path += "?\(tags != nil ? "&tags=\(tags?.joined(separator: "&") ?? "")" : "")"

    return NetworkManager.getElement(on: URL(string: path)!, authorization: authorization, contentType: contentType)
.tryMap { data, response in
        guard let r = response as? HTTPURLResponse, 200..<299 ~= r.statusCode else {
        let httpResponse = response as! HTTPURLResponse

        if httpResponse.statusCode == 400 {
    throw _OpenAPIError.urlError(URLError(URLError.Code(rawValue: 400)))
}

            throw _OpenAPIError.urlError(URLError(URLError.Code(rawValue: httpResponse.statusCode)))
        }
        return data
}
.decode(type: [_Pet].self, decoder: decoder)
    .receive(on: DispatchQueue.main)
    .eraseToAnyPublisher()
}

/**
Returns a single pet

Responses:
    - 404: Pet not found
    - 200: successful operation
    - 400: Invalid ID supplied
*/
public static func getPetById(petId: Int64, authorization: HTTPAuthorization = NetworkManager.authorization!, contentType: String? = NetworkManager.defaultContentType) -> AnyPublisher<_Pet, Error> {
var path = NetworkManager.basePath! + "/pet/{petId}"
    path = path.replacingOccurrences(of: "{petId}", with: String(petId))


    return NetworkManager.getElement(on: URL(string: path)!, authorization: authorization, contentType: contentType)
.tryMap { data, response in
        guard let r = response as? HTTPURLResponse, 200..<299 ~= r.statusCode else {
        let httpResponse = response as! HTTPURLResponse

        if httpResponse.statusCode == 404 {
    let content = String(data: data, encoding: .utf8)!
throw _OpenAPIError.responseStringError(404, content)
}
if httpResponse.statusCode == 400 {
    throw _OpenAPIError.urlError(URLError(URLError.Code(rawValue: 400)))
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
Update an existing pet by Id
RequestBody:
    - element Update an existent pet in the store
Responses:
    - 405: Validation exception
    - 400: Invalid ID supplied
    - 404: Pet not found
    - 200: Successful operation
*/
public static func updatePet(element: _Pet, authorization: HTTPAuthorization = NetworkManager.authorization!, contentType: String? = NetworkManager.defaultContentType) -> AnyPublisher<_Pet, Error> {
var path = NetworkManager.basePath! + "/pet"

    return NetworkManager.putElement(element, authorization: authorization, on: URL(string: path)!, contentType: contentType)
.tryMap { data, response in
        guard let r = response as? HTTPURLResponse, 200..<299 ~= r.statusCode else {
        let httpResponse = response as! HTTPURLResponse

        if httpResponse.statusCode == 405 {
    throw _OpenAPIError.urlError(URLError(URLError.Code(rawValue: 405)))
}
if httpResponse.statusCode == 400 {
    throw _OpenAPIError.urlError(URLError(URLError.Code(rawValue: 400)))
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
public static func updatePetWithForm(petId: Int64, name: String, status: String, authorization: HTTPAuthorization = NetworkManager.authorization!, contentType: String? = NetworkManager.defaultContentType) -> AnyPublisher<String, Error> {
var path = NetworkManager.basePath! + "/pet/{petId}"
    path = path.replacingOccurrences(of: "{petId}", with: String(petId))
path += "?name=\(name.description)&status=\(status.description)"

    return NetworkManager.postElement(authorization: authorization, on: URL(string: path)!, contentType: contentType)
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

/**

RequestBody:
    - element
Responses:
    - 200: successful operation
*/
public static func uploadFile(petId: Int64, additionalMetadata: String?, element: String?, authorization: HTTPAuthorization = NetworkManager.authorization!, contentType: String? = "application/octet-stream") -> AnyPublisher<_ApiResponse, Error> {
var path = NetworkManager.basePath! + "/pet/{petId}/uploadImage"
    path = path.replacingOccurrences(of: "{petId}", with: String(petId))
path += "?\(additionalMetadata != nil ? "&additionalMetadata=\(additionalMetadata?.description ?? "")" : "")"

    return NetworkManager.postElement(element, authorization: authorization, on: URL(string: path)!, contentType: contentType)
.tryMap { data, response in
        guard let r = response as? HTTPURLResponse, 200..<299 ~= r.statusCode else {
        let httpResponse = response as! HTTPURLResponse

        

            throw _OpenAPIError.urlError(URLError(URLError.Code(rawValue: httpResponse.statusCode)))
        }
        return data
}
.decode(type: _ApiResponse.self, decoder: decoder)
    .receive(on: DispatchQueue.main)
    .eraseToAnyPublisher()
}


}
