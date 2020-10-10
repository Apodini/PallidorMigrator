import Foundation
import Combine
import JavaScriptCore

public struct StoreAPI {
    static let decoder : JSONDecoder = NetworkManager.decoder

    public static func deleteOrder(orderId: Int64 , authorization: HTTPAuthorization?  = NetworkManager.authorization, contentType: String?  = NetworkManager.defaultContentType) -> AnyPublisher<String, Error> {

return _StoreAPI.deleteOrder(orderId: orderId, authorization: authorization, contentType: contentType)
.mapError({($0 as! OpenAPIError)})
.receive(on: DispatchQueue.main)
.eraseToAnyPublisher()
}

public static func getInventory(authorization: HTTPAuthorization  = NetworkManager.authorization!, contentType: String?  = NetworkManager.defaultContentType) -> AnyPublisher<[String:Int32], Error> {

return _StoreAPI.getInventory(authorization: authorization, contentType: contentType)
.mapError({($0 as! OpenAPIError)})
.receive(on: DispatchQueue.main)
.eraseToAnyPublisher()
}

public static func getOrderById(orderId: Int64 , authorization: HTTPAuthorization?  = NetworkManager.authorization, contentType: String?  = NetworkManager.defaultContentType) -> AnyPublisher<Order, Error> {

return _StoreAPI.getOrderById(orderId: orderId, authorization: authorization, contentType: contentType)
.mapError({($0 as! OpenAPIError)})
.map({Order($0)!})
.receive(on: DispatchQueue.main)
.eraseToAnyPublisher()
}

public static func placeOrder(element: Order, authorization: HTTPAuthorization?  = NetworkManager.authorization, contentType: String?  = NetworkManager.defaultContentType) -> AnyPublisher<Order, Error> {
let context = JSContext()!
context.evaluateScript("""
function conversion(placeholder) { return placeholder }
""")

let elementEncoded = try! JSONEncoder().encode(element)

let elementTmp = context.objectForKeyedSubscript("conversion").call(withArguments: [String(data: elementEncoded, encoding: .utf8)!])?.toString()

let element = try! JSONDecoder().decode(Customer.self, from: elementTmp!.data(using: .utf8)!)
return _StoreAPI.placeOrder(element: element.to()!, authorization: authorization, contentType: contentType)
.mapError({($0 as! OpenAPIError)})
.map({Order($0)!})
.receive(on: DispatchQueue.main)
.eraseToAnyPublisher()
}

}
