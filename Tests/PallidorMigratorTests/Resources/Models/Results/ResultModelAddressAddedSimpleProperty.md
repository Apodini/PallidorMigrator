import Foundation


public class Address  : Codable {
var city : String?
var state : String?
var street : String?
var zip : String?



init(city: String? = nil, state: String?, street: String?, zip: String?){
self.city = city ?? "No city"
self.state = state
self.street = street
self.zip = zip
}

init?(_ from : _Address?) {
    if let from = from {

    self.city = from.city
self.state = from.state
self.street = from.street
self.zip = from.zip
    } else {
    return nil
    }
}

func to() -> _Address? {

return _Address(city: self.city, state: self.state, street: self.street, zip: self.zip)
}

}
