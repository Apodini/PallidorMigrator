import Foundation
import JavaScriptCore

public class PaymentInstallmentSchedule  : Codable {
var type : String
//sourcery: isCustomInternalEnumType
var of : OneOf

//sourcery: OfTypeEnum
public enum OneOf : Codable {
    case psiInstallmentSchedule(PsiInstallmentSchedule)
case psdInstallmentSchedule(PsdInstallmentSchedule)

    public func encode(to encoder: Encoder) throws {
           switch self {
                case .psiInstallmentSchedule(let of):
    try of.encode(to: encoder)
    break
case .psdInstallmentSchedule(let of):
    try of.encode(to: encoder)
    break
           }
}

public init(from decoder: Decoder) throws {
    
    if let psiInstallmentSchedule = try? PsiInstallmentSchedule.init(from: decoder) {
    self = .psiInstallmentSchedule(psiInstallmentSchedule)
    return
}
if let psdInstallmentSchedule = try? PsdInstallmentSchedule.init(from: decoder) {
    self = .psdInstallmentSchedule(psdInstallmentSchedule)
    return
}
    
    throw APIEncodingError.canNotEncodeOfType(OneOf.self)
}

    func to() -> _PaymentInstallmentSchedule.OneOf {
        switch self {
            case .psiInstallmentSchedule(let ofType):
return _PaymentInstallmentSchedule.OneOf.psiInstallmentSchedule(ofType.to()!)
case .psdInstallmentSchedule(let ofType):
return _PaymentInstallmentSchedule.OneOf.psdInstallmentSchedule(ofType.to()!)
        }
    }
    
    init?(_ from: _PaymentInstallmentSchedule.OneOf?) {
        if let from = from {
            switch from {
                        case .psiInstallmentSchedule(let fromType):
self = .psiInstallmentSchedule(PsiInstallmentSchedule(fromType)!)
break
case .psdInstallmentSchedule(let fromType):
self = .psdInstallmentSchedule(PsdInstallmentSchedule(fromType)!)
break
                    }
        } else {
            return nil
        }
    }

}

init(of: OneOf, type: String){
self.of = of
self.type = type
}

init?(_ from : _PsiInstallmentSchedule?) {
    if let from = from {
    let context = JSContext()!
    let fromEncoded = try! JSONEncoder().encode(from)
    context.evaluateScript("""
    function conversion(o) { return JSON.stringify({ 'type': '', 'of' : { 'type': 'PSI'} } )}
    """)
    let encodedResult = context.objectForKeyedSubscript("conversion").call(withArguments: [String(data: fromEncoded, encoding: .utf8)!])?.toString()
    let from = try! JSONDecoder().decode(PaymentInstallmentSchedule.self, from: encodedResult!.data(using: .utf8)!)
    self.type = from.type
self.of = from.of
    } else {
    return nil
    }
}

func to() -> _PsiInstallmentSchedule? {
let context = JSContext()!
let selfEncoded = try! JSONEncoder().encode(self)
context.evaluateScript("""
function conversion(o) { return JSON.stringify({ 'type' : 'PSI' } )}
""")
let encodedResult = context.objectForKeyedSubscript("conversion").call(withArguments: [String(data: selfEncoded, encoding: .utf8)!])?.toString()
return try! JSONDecoder().decode(_PsiInstallmentSchedule.self, from: encodedResult!.data(using: .utf8)!)
}

}
