import Foundation


public class Order  : Codable {
var complete : Bool?
var id : Int64?
var petId : Int64?
var quantity : Int32?
var shipDate : Date?
var status : Status?

public enum Status : String, Codable, CaseIterable {
    case placed = "placed"
case approved = "approved"
case delivered = "delivered"

    func to() -> _Order.Status? {
        _Order.Status(rawValue : self.rawValue)
    }
    
    init?(_ from: _Order.Status?) {
        if let from = from {
            self.init(rawValue: from.rawValue)
        } else {
            return nil
        }
    }

}

init(complete: Bool?, id: Int64?, petId: Int64?, quantity: Int32?, shipDate: Date?, status: Status?){
self.complete = complete
self.id = id
self.petId = petId
self.quantity = quantity
self.shipDate = shipDate
self.status = status
}

init?(_ from : _Order?) {
    if let from = from {

    self.complete = from.complete
self.id = from.id
self.petId = from.petId
self.quantity = from.quantity
self.shipDate = from.shipDate
self.status = Status(from.status)
    } else {
    return nil
    }
}

func to() -> _Order? {
    
    return _Order(complete: self.complete, id: self.id, petId: self.petId, quantity: self.quantity, shipDate: self.shipDate, status: self.status?.to())
}

}
