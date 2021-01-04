import Foundation


public class PaymentInstallmentSchedule  : Codable {
var type : String
//sourcery: isCustomInternalEnumType
var of : OneOf

//sourcery: OfTypeEnum
public enum OneOf : Codable {
    case psiInstallmentSchedule(PsiInstallmentSchedule)
@available(*, unavailable, message: "This case is unavailable by API version: xxx")
case psdInstallmentSchedule(PsdInstallmentSchedule)

    public func encode(to encoder: Encoder) throws {
           switch self {
                case .psiInstallmentSchedule(let of):
    try of.encode(to: encoder)
    break

           }
}

public init(from decoder: Decoder) throws {

    if let psiInstallmentSchedule = try? PsiInstallmentSchedule.init(from: decoder) {
    self = .psiInstallmentSchedule(psiInstallmentSchedule)
    return
}


    throw APIEncodingError.canNotEncodeOfType(OneOf.self)
}

    func to() -> _PaymentInstallmentSchedule.OneOf {
        switch self {
            case .psiInstallmentSchedule(let ofType):
return _PaymentInstallmentSchedule.OneOf.psiInstallmentSchedule(ofType.to()!)

        }
    }

    init?(_ from: _PaymentInstallmentSchedule.OneOf?) {
        if let from = from {
            switch from {
                        case .psiInstallmentSchedule(let fromType):
self = .psiInstallmentSchedule(PsiInstallmentSchedule(fromType)!)
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

init?(_ from : _PaymentInstallmentSchedule?) {
    if let from = from {

    self.type = from.type
self.of = OneOf(from.of)!
    } else {
    return nil
    }
}

func to() -> _PaymentInstallmentSchedule? {

return _PaymentInstallmentSchedule(of: self.of.to(), type: self.type)
}

}
