import Foundation

public enum OpenAPIError: Error {
    case responseStringError(Int, String)
case urlError(URLError)
        
init?(_ from: _OpenAPIError?) {
    if let from = from {
        switch from {
            case .responseStringError(let int, let string):
  self = .responseStringError(int, string)
case .urlError(let uRLError):
  self = .urlError(uRLError)
        }
    } else {
        return nil
    }
}

}
