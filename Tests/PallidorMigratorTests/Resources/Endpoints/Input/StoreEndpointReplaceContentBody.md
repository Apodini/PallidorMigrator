import Foundation
import Combine


struct _StoreAPI {
    static let decoder : JSONDecoder = NetworkManager.decoder

/**
For valid response try integer IDs with value < 1000. Anything above 1000 or nonintegers will generate API errors

Responses:
    - 404: Order not found
    - 400: Invalid ID supplied
*/
public static func deleteOrder(orderId: Int64, authorization: HTTPAuthorization? = NetworkManager.authorization, contentType: String? = NetworkManager.defaultContentType) -> AnyPublisher<String, Error> {
var path = NetworkManager.basePath! + "/store/order/{orderId}"
    path = path.replacingOccurrences(of: "{orderId}", with: String(orderId))


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
Returns a map of status codes to quantities

Responses:
    - 200: successful operation
*/
public static func getInventory(authorization: HTTPAuthorization = NetworkManager.authorization!, contentType: String? = NetworkManager.defaultContentType) -> AnyPublisher<[String:Int32], Error> {
let path = NetworkManager.basePath! + "/store/inventory"
    


    return NetworkManager.getElement(on: URL(string: path)!, authorization: authorization, contentType: contentType)
.tryMap { data, response in
        guard let r = response as? HTTPURLResponse, 200..<299 ~= r.statusCode else {
        let httpResponse = response as! HTTPURLResponse

        

            throw _OpenAPIError.urlError(URLError(URLError.Code(rawValue: httpResponse.statusCode)))
        }
        return data
}
.decode(type: [String:Int32].self, decoder: decoder)
    .receive(on: DispatchQueue.main)
    .eraseToAnyPublisher()
}

/**
For valid response try integer IDs with value <= 5 or > 10. Other values will generated exceptions

Responses:
    - 400: Invalid ID supplied
    - 200: successful operation
    - 404: Order not found
*/
public static func getOrderById(orderId: Int64, authorization: HTTPAuthorization? = NetworkManager.authorization, contentType: String? = NetworkManager.defaultContentType) -> AnyPublisher<_Order, Error> {
var path = NetworkManager.basePath! + "/store/order/{orderId}"
    path = path.replacingOccurrences(of: "{orderId}", with: String(orderId))


    return NetworkManager.getElement(on: URL(string: path)!, authorization: authorization, contentType: contentType)
.tryMap { data, response in
        guard let r = response as? HTTPURLResponse, 200..<299 ~= r.statusCode else {
        let httpResponse = response as! HTTPURLResponse

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
.decode(type: _Order.self, decoder: decoder)
    .receive(on: DispatchQueue.main)
    .eraseToAnyPublisher()
}

/**
Place a new order in the store
RequestBody:
    - element
Responses:
    - 405: Invalid input
    - 200: successful operation
*/
public static func placeOrder(element: _Customer?, authorization: HTTPAuthorization? = NetworkManager.authorization, contentType: String? = NetworkManager.defaultContentType) -> AnyPublisher<_Order, Error> {
let path = NetworkManager.basePath! + "/store/order"
    


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
.decode(type: _Order.self, decoder: decoder)
    .receive(on: DispatchQueue.main)
    .eraseToAnyPublisher()
}


}
