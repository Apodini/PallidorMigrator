import Foundation
import JavaScriptCore

public enum MessageLevel: String, Codable, CaseIterable {
    case INFO
case WARNING
case ERROR

func to() -> _ServiceLevel? {
    let context = JSContext()!
    context.evaluateScript("""
    function conversion(o) { return o === 'INFO' ? 1 : 2 }
    """)
    let toTmp = context.objectForKeyedSubscript("conversion").call(withArguments: [self.rawValue])?.toString()
    return _ServiceLevel(rawValue: Int(toTmp!)!)
}

init?(_ from: _ServiceLevel?) {
    if let from = from {
        let context = JSContext()!
        context.evaluateScript("""
        function conversion(o) { return o === 1 ? 'INFO' : 'ERROR' }
        """)
        let fromTmp = context.objectForKeyedSubscript("conversion").call(withArguments: [from.rawValue])?.toString()
        self.init(rawValue: fromTmp!)
    } else {
        return nil
    }
}

}
