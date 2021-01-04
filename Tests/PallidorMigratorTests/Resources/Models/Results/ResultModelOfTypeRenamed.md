import Foundation


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

    func to() -> _PayInstallSched.OneOf {
        switch self {
            case .psiInstallmentSchedule(let ofType):
return _PayInstallSched.OneOf.psiInstallmentSchedule(ofType.to()!)
case .psdInstallmentSchedule(let ofType):
return _PayInstallSched.OneOf.psdInstallmentSchedule(ofType.to()!)
        }
    }

    init?(_ from: _PayInstallSched.OneOf?) {
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

init?(_ from : _PayInstallSched?) {
    if let from = from {

    self.type = from.type
self.of = OneOf(from.of)!
    } else {
    return nil
    }
}

func to() -> _PayInstallSched? {

return _PayInstallSched(of: self.of.to(), type: self.type)
}

}
