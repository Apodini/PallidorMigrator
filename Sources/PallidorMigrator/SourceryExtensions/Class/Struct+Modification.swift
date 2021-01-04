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
        let rename = Endpoint.endpointName(from: change.originalId)

        if let facadeEndpoint = CodeStore.getInstance().getEndpoint(change.originalId) {
            guard let renamed = facadeEndpoint.copy() as? WrappedStruct else {
                fatalError("Endpoint cloning failed.")
            }
            renamed.localName = rename
            CodeStore.getInstance().insert(modifiable: renamed)
        }

        self.localName = rename

        for method in methods {
            method.modify(change: change)
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
