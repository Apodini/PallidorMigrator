import Foundation

class _NewCustomer: Codable {


//sourcery: isCustomType
var  addresses: [_NewAddress]?
var  id: Int64?
var  username: String?

init(addresses: [_NewAddress]?, id: Int64?, username: String?) {

        self.id = id
self.username = username
self.addresses = addresses
    }
    
}
