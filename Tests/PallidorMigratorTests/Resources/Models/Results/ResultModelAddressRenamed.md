import Foundation


public class Address  : Codable {
var city : String?
var state : String?
var street : String?
var zip : String?



init(city: String?, state: String?, street: String?, zip: String?){
self.city = city
self.state = state
self.street = street
self.zip = zip
}

init?(_ from : _NewAddress?) {
    if let from = from {

    self.city = from.city
self.state = from.state
self.street = from.street
self.zip = from.zip
    } else {
    return nil
    }
}

func to() -> _NewAddress? {

return _NewAddress(city: self.city, state: self.state, street: self.street, zip: self.zip)
}

}
