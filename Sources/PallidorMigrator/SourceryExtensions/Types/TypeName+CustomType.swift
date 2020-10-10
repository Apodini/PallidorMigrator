//
//  TypeName+CustomType.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation
import SourceryRuntime

extension WrappedTypeName {
    /// maps the publisher success type from api to facade type
    var mappedPublisherType: String {
        let unmappedType = name.replacingOccurrences(of: "AnyPublisher<", with: "").replacingOccurrences(of: ", Error>", with: "")
        return "AnyPublisher<\(unmappedType.replacingOccurrences(of: "_", with: "").unwrapped), Error>"
    }
    
    /// success type without `AnyPublisher` wrapper
    var mappedPublisherSuccessType: String {
        mappedPublisherType.replacingOccurrences(of: "AnyPublisher<", with: "").replacingOccurrences(of: ", Error>", with: "")
    }
    
    /// removes optional and collection characters from type name
    var underlyingType: String {
        isOptional && isArray ? "\(name.unwrapped.dropLast().dropFirst())" : (isOptional ? "\(name.unwrapped)" : (isArray ? "\(name.dropLast().dropFirst())" : name))
    }
}
