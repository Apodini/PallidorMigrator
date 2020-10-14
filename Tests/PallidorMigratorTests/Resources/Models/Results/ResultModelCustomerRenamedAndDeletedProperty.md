import Foundation


public class Customer  : Codable {
var id : Int64?
var username : String?
var addresses : [NewAddresses]?



init(addresses: [NewAddresses]?, id: Int64?, username: String?){
self.addresses = addresses
self.id = id
self.username = username
}

init?(_ from : _NewCustomer?) {
    if let from = from {

    self.id = from.id
self.username = from.username
self.addresses = try JSONDecoder().decode([NewAddresses].self, from: "[{'name' : 'myaddress'}]".data(using: .utf8)!
    } else {
    return nil
    }
}

func to() -> _NewCustomer? {

return _NewCustomer(id: self.id, username: self.username)
}

}
