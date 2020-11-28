//
//  Method+StringBuilder.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation
import SourceryRuntime

extension WrappedMethod {
    /// signature of method
    var signatureString: String {
        isInitializer ?
            """
            public \(getPersistentInitializer(self))\(self.throws ? " throws" : "" )
            """ :
        """
        public \(isStatic ? "static ": "")func \(persistentName)\(self.throws ? " throws" : "" )\(!returnTypeName.isVoid ? " -> \(returnTypeName.mappedPublisherType)" : "")
        """
    }
    
    /// `map()` method for result mapping
    var apiMethodResultMap: String {
        get {
            let mappedType = returnTypeName.mappedPublisherSuccessType
            let mapString = self.mapString(mappedType)
            
            return """
            \(apiMethodErrorMap)\(mapString != nil ? "\n\(mapString!)" : "")
            \(apiMethodEraseToPublisher)
            """
        }
    }
    
    /// `mapError()` method for error mapping
    var apiMethodErrorMap: String {
        ".mapError({( OpenAPIError($0 as? _OpenAPIError)! )})"
    }
    
    /// default `receive()` & `eraseToAnyPublisher()` string
    var apiMethodEraseToPublisher: String {
        """
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
        """
    }
}
