import Foundation
import JavaScriptCore

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
}

init(complete: Bool?, id: Int64?, petId: Int64?, quantity: Int32?, shipDate: Date?, status: Status?){
self.complete = complete
self.id = id
self.petId = petId
self.quantity = quantity
self.shipDate = shipDate
self.status = status
}

init?(_ from : _NewOrder?) {
    if let from = from {
    let context = JSContext()!
    let fromEncoded = try! JSONEncoder().encode(from)
    context.evaluateScript("""
    function conversion(o) { return JSON.stringify({ 'id' : o.id, 'petId' : o.petId, 'quantity': o.quantity, 'complete' : 'false', 'status' : 'available' }) }
    """)
    let encodedResult = context.objectForKeyedSubscript("conversion").call(withArguments: [String(data: fromEncoded, encoding: .utf8)!])?.toString()
    let from = try! JSONDecoder().decode(Order.self, from: encodedResult!.data(using: .utf8)!)
    self.complete = from.complete
self.id = from.id
self.petId = from.petId
self.quantity = from.quantity
self.shipDate = from.shipDate
self.status = from.status
    } else {
    return nil
    }
}

func to() -> _NewOrder? {
let context = JSContext()!
let selfEncoded = try! JSONEncoder().encode(self)
context.evaluateScript("""
function conversion(o) { return JSON.stringify({ 'id' : o.id, 'petId' : o.petId, 'quantity': o.quantity  }) }
""")
let encodedResult = context.objectForKeyedSubscript("conversion").call(withArguments: [String(data: selfEncoded, encoding: .utf8)!])?.toString()
return try! JSONDecoder().decode(_NewOrder.self, from: encodedResult!.data(using: .utf8)!)
}

}
