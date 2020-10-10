import Foundation

public enum TimeMode: String, Codable {
    case UTC = "UTC"
case LT = "LT"

func to() -> _TimeRenamedMode? {
    _TimeRenamedMode(rawValue: self.rawValue)
}

init?(_ from: _TimeRenamedMode?) {
    if let from = from {
        self.init(rawValue: from.rawValue)
    } else {
        return nil
    }
}

}
