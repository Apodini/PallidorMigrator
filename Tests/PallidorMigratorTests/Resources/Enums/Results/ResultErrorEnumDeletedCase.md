import Foundation

public enum OpenAPIError: Error {
    @available(*, unavailable, message: "This case is unavailable by API version: xxx")
case responseStringError(Int, String)
case urlError(URLError)

init?(_ from: _OpenAPIError?) {
    if let from = from {
        switch from {
            case .urlError(let uRLError):
  self = .urlError(uRLError)
        }
    } else {
        return nil
    }
}

}
