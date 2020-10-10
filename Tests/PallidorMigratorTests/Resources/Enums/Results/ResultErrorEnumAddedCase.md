import Foundation

public enum OpenAPIError: Error {
    case responseStringError(Int, String)
case urlError(URLError)
case responsePetError(Int, Pet)
        
init?(_ from: _OpenAPIError?) {
    if let from = from {
        switch from {
            case .responseStringError(let int, let string):
  self = .responseStringError(int, string)
case .urlError(let uRLError):
  self = .urlError(uRLError)
case .responsePetError(let int, let pet):
  self = .responsePetError(int, Pet(pet)!)
        }
    } else {
        return nil
    }
}

}
