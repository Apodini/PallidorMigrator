import Foundation


public class ApiResponse  : Codable {
var code : Int32?
var message : String?
var type : String?



init(code: Int32?, message: String?, type: String?){
self.code = code
self.message = message
self.type = type
}

init?(_ from : _ApiResponse?) {
    if let from = from {

    self.code = from.code
self.message = from.message
self.type = from.type
    } else {
    return nil
    }
}

func to() -> _ApiResponse? {
    
    return _ApiResponse(code: self.code, message: self.message, type: self.type)
}

}
