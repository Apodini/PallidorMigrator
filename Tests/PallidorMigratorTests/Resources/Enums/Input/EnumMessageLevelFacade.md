import Foundation

public enum MessageLevel: String, Codable, CaseIterable {
    case INFO
case WARNING
case ERROR

func to() -> _MessageLevel? {
    _MessageLevel(rawValue: self.rawValue)
}

init?(_ from: _MessageLevel?) {
    if let from = from {
        self.init(rawValue: from.rawValue)
    } else {
        return nil
    }
}

}
