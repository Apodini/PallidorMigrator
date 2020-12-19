import Foundation


public class Category  : Codable {
var id : Int64?
var name : String?



init(id: Int64?, name: String?){
self.id = id
self.name = name
}

init?(_ from : _NewCategory?) {
    if let from = from {

    self.id = from.id
self.name = from.namenew
    } else {
    return nil
    }
}

func to() -> _NewCategory? {

return _NewCategory(id: self.id, namenew: self.name)
}

}
