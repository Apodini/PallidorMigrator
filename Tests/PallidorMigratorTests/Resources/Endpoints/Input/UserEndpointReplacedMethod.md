import Foundation
import Combine


struct _UserAPI {
    static let decoder : JSONDecoder = NetworkManager.decoder

    /**
    Update an existing pet by Id
    RequestBody:
        - element Update an existent pet in the store
    Responses:
        - 404: Pet not found
        - 400: Invalid ID supplied
        - 200: Successful operation
        - 405: Validation exception
    */
    public static func updateMyPet(element: _User, authorization: HTTPAuthorization = NetworkManager.authorization!, contentType: String? = NetworkManager.defaultContentType) -> AnyPublisher<_User, Error> {
    let path = NetworkManager.basePath! + "/user/mypet"

        return NetworkManager.putElement(element, authorization: authorization, on: URL(string: path)!, contentType: contentType)
    .tryMap { data, response in
            guard let r = response as? HTTPURLResponse, 200..<299 ~= r.statusCode else {
            let httpResponse = response as! HTTPURLResponse

            if httpResponse.statusCode == 404 {
        throw _OpenAPIError.urlError(URLError(URLError.Code(rawValue: 404)))
    }
    if httpResponse.statusCode == 400 {
        throw _OpenAPIError.urlError(URLError(URLError.Code(rawValue: 400)))
    }
    if httpResponse.statusCode == 405 {
        throw _OpenAPIError.urlError(URLError(URLError.Code(rawValue: 405)))
    }

                throw _OpenAPIError.urlError(URLError(URLError.Code(rawValue: httpResponse.statusCode)))
            }
            return data
    }
    .decode(type: _User.self, decoder: decoder)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }


/**
This can only be done by the logged in user.
RequestBody:
    - element Created user object
Responses:
    - 200: successful operation
*/
public static func createUser(element: _User?, authorization: HTTPAuthorization? = NetworkManager.authorization, contentType: String? = NetworkManager.defaultContentType) -> AnyPublisher<_User, Error> {
let path = NetworkManager.basePath! + "/user"
    


    return NetworkManager.postElement(element, authorization: authorization, on: URL(string: path)!, contentType: contentType)
.tryMap { data, response in
        guard let r = response as? HTTPURLResponse, 200..<299 ~= r.statusCode else {
        let httpResponse = response as! HTTPURLResponse

        

            throw _OpenAPIError.urlError(URLError(URLError.Code(rawValue: httpResponse.statusCode)))
        }
        return data
}
.decode(type: _User.self, decoder: decoder)
    .receive(on: DispatchQueue.main)
    .eraseToAnyPublisher()
}

/**
Creates list of users with given input array
RequestBody:
    - element
Responses:
    - default: successful operation
    - 200: Successful operation
*/
public static func createUsersWithListInput(element: [_User]?, authorization: HTTPAuthorization? = NetworkManager.authorization, contentType: String? = NetworkManager.defaultContentType) -> AnyPublisher<_User, Error> {
let path = NetworkManager.basePath! + "/user/createWithList"
    


    return NetworkManager.postElement(element, authorization: authorization, on: URL(string: path)!, contentType: contentType)
.tryMap { data, response in
        guard let r = response as? HTTPURLResponse, 200..<299 ~= r.statusCode else {
        let httpResponse = response as! HTTPURLResponse

        

            throw _OpenAPIError.urlError(URLError(URLError.Code(rawValue: httpResponse.statusCode)))
        }
        return data
}
.decode(type: _User.self, decoder: decoder)
    .receive(on: DispatchQueue.main)
    .eraseToAnyPublisher()
}

/**
This can only be done by the logged in user.

Responses:
    - 404: User not found
    - 400: Invalid username supplied
*/
public static func deleteUser(username: String, authorization: HTTPAuthorization? = NetworkManager.authorization, contentType: String? = NetworkManager.defaultContentType) -> AnyPublisher<String, Error> {
var path = NetworkManager.basePath! + "/user/{username}"
    path = path.replacingOccurrences(of: "{username}", with: String(username))


    return NetworkManager.delete(at: URL(string: path)!, authorization: authorization, contentType: contentType)
.tryMap { data, response in
        guard let r = response as? HTTPURLResponse, 200..<299 ~= r.statusCode else {
        let httpResponse = response as! HTTPURLResponse

        if httpResponse.statusCode == 404 {
    throw _OpenAPIError.urlError(URLError(URLError.Code(rawValue: 404)))
}
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


Responses:
    - 404: User not found
    - 200: successful operation
    - 400: Invalid username supplied
*/
public static func getUserByName(username: String, authorization: HTTPAuthorization? = NetworkManager.authorization, contentType: String? = NetworkManager.defaultContentType) -> AnyPublisher<_User, Error> {
var path = NetworkManager.basePath! + "/user/{username}"
    path = path.replacingOccurrences(of: "{username}", with: String(username))


    return NetworkManager.getElement(on: URL(string: path)!, authorization: authorization, contentType: contentType)
.tryMap { data, response in
        guard let r = response as? HTTPURLResponse, 200..<299 ~= r.statusCode else {
        let httpResponse = response as! HTTPURLResponse

        if httpResponse.statusCode == 404 {
    throw _OpenAPIError.urlError(URLError(URLError.Code(rawValue: 404)))
}
if httpResponse.statusCode == 400 {
    throw _OpenAPIError.urlError(URLError(URLError.Code(rawValue: 400)))
}

            throw _OpenAPIError.urlError(URLError(URLError.Code(rawValue: httpResponse.statusCode)))
        }
        return data
}
.decode(type: _User.self, decoder: decoder)
    .receive(on: DispatchQueue.main)
    .eraseToAnyPublisher()
}

/**


Responses:
    - 400: Invalid username/password supplied
    - 200: successful operation
*/
public static func loginUser(password: String?, username: String?, authorization: HTTPAuthorization? = NetworkManager.authorization, contentType: String? = NetworkManager.defaultContentType) -> AnyPublisher<String, Error> {
var path = NetworkManager.basePath! + "/user/login"
    
path += "?\(username != nil ? "&username=\(username?.description ?? "")" : "")\(password != nil ? "&password=\(password?.description ?? "")" : "")"

    return NetworkManager.getElement(on: URL(string: path)!, authorization: authorization, contentType: contentType)
.tryMap { data, response in
        guard let r = response as? HTTPURLResponse, 200..<299 ~= r.statusCode else {
        let httpResponse = response as! HTTPURLResponse

        if httpResponse.statusCode == 400 {
    let content = String(data: data, encoding: .utf8)!
throw _OpenAPIError.responseStringError(400, content)
}

            throw _OpenAPIError.urlError(URLError(URLError.Code(rawValue: httpResponse.statusCode)))
        }
        return String(data: data, encoding: .utf8)!
}
    .receive(on: DispatchQueue.main)
    .eraseToAnyPublisher()
}

/**


Responses:
    - default: successful operation
*/
public static func logoutUser(authorization: HTTPAuthorization? = NetworkManager.authorization, contentType: String? = NetworkManager.defaultContentType) -> AnyPublisher<String, Error> {
let path = NetworkManager.basePath! + "/user/logout"
    


    return NetworkManager.getElement(on: URL(string: path)!, authorization: authorization, contentType: contentType)
.tryMap { data, response in
        guard let r = response as? HTTPURLResponse, 200..<299 ~= r.statusCode else {
        let httpResponse = response as! HTTPURLResponse

        

            throw _OpenAPIError.urlError(URLError(URLError.Code(rawValue: httpResponse.statusCode)))
        }
        return String(data: data, encoding: .utf8)!
}
    .receive(on: DispatchQueue.main)
    .eraseToAnyPublisher()
}

/**
This can only be done by the logged in user.
RequestBody:
    - element Update an existent user in the store
Responses:
    - default: successful operation
*/
public static func updateUser(username: String, element: _User?, authorization: HTTPAuthorization? = NetworkManager.authorization, contentType: String? = NetworkManager.defaultContentType) -> AnyPublisher<String, Error> {
var path = NetworkManager.basePath! + "/user/{username}"
    path = path.replacingOccurrences(of: "{username}", with: String(username))


    return NetworkManager.putElement(element, authorization: authorization, on: URL(string: path)!, contentType: contentType)
.tryMap { data, response in
        guard let r = response as? HTTPURLResponse, 200..<299 ~= r.statusCode else {
        let httpResponse = response as! HTTPURLResponse

        

            throw _OpenAPIError.urlError(URLError(URLError.Code(rawValue: httpResponse.statusCode)))
        }
        return String(data: data, encoding: .utf8)!
}
    .receive(on: DispatchQueue.main)
    .eraseToAnyPublisher()
}


}
