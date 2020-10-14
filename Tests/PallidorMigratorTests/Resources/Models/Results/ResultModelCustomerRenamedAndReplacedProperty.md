import Foundation
import JavaScriptCore

public class Customer  : Codable {
var address : [Address]?
var id : Int64?
var username : String?



init(address: [Address]?, id: Int64?, username: String?){
self.address = address
self.id = id
self.username = username
}

init?(_ from : _NewCustomer?) {
    if let from = from {
let context = JSContext()!
    context.evaluateScript("""
function conversion(address) { return address.universe == '42' ? { 'city' : address.city, 'street' : address.street, 'zip': '81543', 'state' : 'Bavaria' } : { 'city' : address.city, 'street' : address.street , 'zip' : '80634', 'state' : 'Bavaria' } }
""")
    let addressesEncoded = try! JSONEncoder().encode(from.addresses)
    let addressTmp = context.objectForKeyedSubscript("conversion").call(withArguments: [addressesEncoded])?.toString()
    let address = try! JSONDecoder().decode([Address].self, from: addressTmp!.data(using: .utf8)!)
    self.address = address
self.id = from.id
self.username = from.username
    } else {
    return nil
    }
}

func to() -> _NewCustomer? {
let context = JSContext()!
context.evaluateScript("""
function conversion(address) { return { 'city' : address.city, 'street' : address.street, 'universe' : '42' } }
""")

let addressEncoded = try! JSONEncoder().encode(address)

let addressesTmp = context.objectForKeyedSubscript("conversion").call(withArguments: [addressEncoded])?.toString()

let addresses = try! JSONDecoder().decode([NewAddress].self, from: addressesTmp!.data(using: .utf8)!)
return _NewCustomer(addresses: addresses.map({ $0.to()! }), id: self.id, username: self.username)
}

}
