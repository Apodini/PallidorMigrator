//
//  Struct+Modification.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

extension WrappedStruct {
    /// handle renaming an endpoint
    /// - Parameter change: RenameChange affecting this endpoint
    internal func handleEndpointRenameChange(_ change: RenameChange) {
        
        self.localName = Endpoint.endpointName(from: change.originalId)
       
        for m in methods {
            m.modify(change: change)
        }
    }
    
    /// handle deleting an endpoint
    /// - Parameter change: DeleteChange affecting this endpoint
    internal func handleEndpointDeletedChange(_ change: DeleteChange) {
        self.methods = []
        self.variables = []
        self.annotation = Annotation.unavailable(msg: "This endpoint is unavailable by API version: xxx")
    }
}
