import Foundation

public enum TimeMode: String, Codable {
    case UTC = "UTC"
case LT = "LT"

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
