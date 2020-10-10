import Foundation
import Combine


public struct UserAPI {
    static let decoder : JSONDecoder = NetworkManager.decoder

    public static func createUser(element: User? , authorization: HTTPAuthorization?  = NetworkManager.authorization, contentType: String?  = NetworkManager.defaultContentType) -> AnyPublisher<User, Error> {

return _UserAPI.createUser(element: element?.to()!, authorization: authorization, contentType: contentType)
.mapError({($0 as! OpenAPIError)})
.map({User($0)!})
.receive(on: DispatchQueue.main)
.eraseToAnyPublisher()
}

public static func createUsersWithListInput(element: [User]? , authorization: HTTPAuthorization?  = NetworkManager.authorization, contentType: String?  = NetworkManager.defaultContentType) -> AnyPublisher<User, Error> {

return _UserAPI.createUsersWithListInput(element: element?.map({$0.to()!}), authorization: authorization, contentType: contentType)
.mapError({($0 as! OpenAPIError)})
.map({User($0)!})
.receive(on: DispatchQueue.main)
.eraseToAnyPublisher()
}

public static func deleteUser(username: String , authorization: HTTPAuthorization?  = NetworkManager.authorization, contentType: String?  = NetworkManager.defaultContentType) -> AnyPublisher<String, Error> {

return _UserAPI.deleteUser(username: username, authorization: authorization, contentType: contentType)
.mapError({($0 as! OpenAPIError)})
.receive(on: DispatchQueue.main)
.eraseToAnyPublisher()
}

public static func getUserByName(username: String , authorization: HTTPAuthorization?  = NetworkManager.authorization, contentType: String?  = NetworkManager.defaultContentType) -> AnyPublisher<User, Error> {

return _UserAPI.getUserByName(username: username, authorization: authorization, contentType: contentType)
.mapError({($0 as! OpenAPIError)})
.map({User($0)!})
.receive(on: DispatchQueue.main)
.eraseToAnyPublisher()
}

public static func loginUser(username: String? , password: String? , authorization: HTTPAuthorization?  = NetworkManager.authorization, contentType: String?  = NetworkManager.defaultContentType) -> AnyPublisher<String, Error> {

return _UserAPI.loginUser(username: username, password: password, authorization: authorization, contentType: contentType)
.mapError({($0 as! OpenAPIError)})
.receive(on: DispatchQueue.main)
.eraseToAnyPublisher()
}

public static func logoutUser(authorization: HTTPAuthorization?  = NetworkManager.authorization, contentType: String?  = NetworkManager.defaultContentType) -> AnyPublisher<String, Error> {

return _UserAPI.logoutUser(authorization: authorization, contentType: contentType)
.mapError({($0 as! OpenAPIError)})
.receive(on: DispatchQueue.main)
.eraseToAnyPublisher()
}

public static func updateUser(username: String? , element: User? , authorization: HTTPAuthorization?  = NetworkManager.authorization, contentType: String?  = NetworkManager.defaultContentType) -> AnyPublisher<String, Error> {

return _UserAPI.updateUser(element: element?.to()!, authorization: authorization, contentType: contentType)
.mapError({($0 as! OpenAPIError)})
.receive(on: DispatchQueue.main)
.eraseToAnyPublisher()
}

}
