import Foundation

public enum TimeMode: String, Codable {
    case LT = "LT"
@available(*, unavailable, message: "This case is unavailable by API version: xxx")
case UTC = "UTC"

func to() -> _TimeMode? {
    _TimeMode(rawValue: self.rawValue)
}

init?(_ from: _TimeMode?) {
    if let from = from {
        self.init(rawValue: from.rawValue)
    } else {
        return nil
    }
}

}
