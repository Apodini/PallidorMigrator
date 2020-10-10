import Foundation

@available(*, unavailable, message: "This model is unavailable by API version: xxx")
public class ApiResponse  : Codable {
var code : Int32?
var message : String?
var type : String?



init(code: Int32?, message: String?, type: String?){
self.code = code
self.message = message
self.type = type
}





}
