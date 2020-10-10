import Foundation


public class Pet  : Codable {
var category : Category?
var id : Int64?
var name : String
var photoUrls : [String]
var status : Status?
var tags : [Tag]?

public enum Status : String, Codable, CaseIterable {
    case available = "available"
case pending = "pending"
case sold = "sold"

    func to() -> _Pet.Status? {
        _Pet.Status(rawValue : self.rawValue)
    }
    
    init?(_ from: _Pet.Status?) {
        if let from = from {
            self.init(rawValue: from.rawValue)
        } else {
            return nil
        }
    }

}

init(category: Category?, id: Int64?, name: String, photoUrls: [String], status: Status?, tags: [Tag]?){
self.category = category
self.id = id
self.name = name
self.photoUrls = photoUrls
self.status = status
self.tags = tags
}

init?(_ from : _Pet?) {
    if let from = from {

    self.category = Category(from.category)
self.id = from.id
self.name = from.name
self.photoUrls = from.photoUrls
self.status = Status(from.status)
self.tags = from.tags?.map({ Tag($0)! })
    } else {
    return nil
    }
}

func to() -> _Pet? {

return _Pet(category: self.category?.to(), id: self.id, name: self.name, photoUrls: self.photoUrls, status: self.status?.to(), tags: self.tags?.map({ $0.to()! }))
}

}
