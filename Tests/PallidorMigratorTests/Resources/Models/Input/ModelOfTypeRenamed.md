import Foundation

class _PayInstallSched: Codable {
    
    var type : String
    
    //sourcery: isCustomInternalEnumType
    var of: OneOf
    
    //sourcery: OfTypeEnum
    enum OneOf : Codable {
        
        case psiInstallmentSchedule(_PsiInstallmentSchedule)
        case psdInstallmentSchedule(_PsdInstallmentSchedule)
        
        
        //sourcery: ignore
        func encode(to encoder: Encoder) throws {
            switch self {
            case .psiInstallmentSchedule(let of):
                try of.encode(to: encoder)
                break
            case .psdInstallmentSchedule(let of):
                try of.encode(to: encoder)
                break
                
            }
        }
        
        //sourcery: ignore
        init(from decoder: Decoder) throws {
            if let psiInstallmentSchedule = try? _PsiInstallmentSchedule.init(from: decoder) {
                self = .psiInstallmentSchedule(psiInstallmentSchedule)
                return
            }
            if let psdInstallmentSchedule = try? _PsdInstallmentSchedule.init(from: decoder) {
                self = .psdInstallmentSchedule(psdInstallmentSchedule)
                return
            }
            
            
            throw APIEncodingError.canNotEncodeOfType(_PayInstallSched.self)
        }
        
    }
    
    init(of: OneOf , type: String){
        self.of = of
        self.type = type
    }
    
    //sourcery: ignore
    private enum CodingKeys : CodingKey {
        case type
    }
    
    //sourcery: ignore
    func encode(to encoder: Encoder) throws {
        try of.encode(to: encoder)
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
    }
    
    //sourcery: ignore
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(String.self, forKey: .type)
        self.of = try OneOf.init(from: decoder)
    }
    
}
