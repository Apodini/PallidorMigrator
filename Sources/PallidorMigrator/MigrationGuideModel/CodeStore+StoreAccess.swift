//
//  CodeStore+StoreAccess.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

/// extension of CodeStore for CodeStore content manipulation & access
extension CodeStore {
    /// inserts a new modifiable into the current api list (for getting deleted source code out of facade into current api)
    /// - Parameter modifiable: deleted source code from facade
    func insertDeleted(modifiable: Modifiable) {
        currentAPI.append(modifiable)
    }

    /// Inserts a modifiable into the code store
    /// - Parameters:
    ///   - modifiable: modifiable to insert
    ///   - current: true if modifiable should be inserted into the current API
    func insert(modifiable: Modifiable, in current: Bool = false) {
        guard guardSearchAccess(current) else {
            fatalError("Tried to insert modifiable in previous facade which is nil.")
        }
        // Safety ensured by `guardSearchAccess()`
        // swiftlint:disable:next force_unwrapping
        current ? currentAPI.append(modifiable) : previousFacade!.append(modifiable)
    }

    /// Retrieves a method
    /// - Parameters:
    ///   - id: identifier of method (e.g. name)
    ///   - searchInCurrent: get method from current api, else previous facade (default)
    /// - Returns: Method if available
    func getMethod(_ id: String, searchInCurrent: Bool = false) -> WrappedMethod? {
        let allMethods = getEndpoints(searchInCurrent: searchInCurrent)
            .map { endp -> [WrappedMethod] in
                guard let endpoint = endp as? WrappedStruct else {
                    fatalError("Could not parse to endpoint")
                }
                return endpoint.methods
            }
            .joined()
        return allMethods.first(where: { $0.id == id })
    }

    /// Retrieves a model
    /// - Parameters:
    ///   - id: identifier of model (e.g. name)
    ///   - searchInCurrent: get model from current api, else previous facade (default)
    /// - Returns: Model if available
    func getModel(_ id: String, searchInCurrent: Bool = false) -> WrappedClass? {
        guard guardSearchAccess(searchInCurrent) else {
            fatalError("Tried to search in previous facade which is not initialized.")
        }
        // Safety ensured by `guardSearchAccess()`
        // swiftlint:disable:next force_unwrapping
        let searchTarget = searchInCurrent ? currentAPI : previousFacade!
        for searchModel in searchTarget {
            if let model = searchModel as? WrappedClass, model.id == id {
                return model
            }
        }
        return nil
    }

    /// Retrieves an Enum
    /// - Parameters:
    ///   - id: identifier of enum (e.g. name)
    ///   - searchInCurrent: get enum from current api, else previous facade (default)
    /// - Returns: Enum if available
    func getEnum(_ id: String, searchInCurrent: Bool = false) -> WrappedEnum? {
        guard guardSearchAccess(searchInCurrent) else {
            fatalError("Tried to search in previous facade which is not initialized.")
        }
        // Safety ensured by `guardSearchAccess()`
        // swiftlint:disable:next force_unwrapping
        let searchTarget = searchInCurrent ? currentAPI : previousFacade!
        for searchEnum in searchTarget {
            if let enumModel = searchEnum as? WrappedEnum, enumModel.id == id {
                return enumModel
            }
        }
        return nil
    }

    /// Retrieves an Endpoint
    /// - Parameters:
    ///   - id: identifier of endpoint (e.g. top level route)
    ///   - searchInCurrent: get endpoint from current api, else previous facade (default)
    /// - Returns: Endpoint if available
    func getEndpoint(_ id: String, searchInCurrent: Bool = false) -> WrappedStruct? {
        guard guardSearchAccess(searchInCurrent) else {
            fatalError("Tried to search in previous facade which is not initialized.")
        }
        let searchTarget = searchInCurrent ? currentAPI : previousFacade
        // Safety ensured by `guardSearchAccess()`
        // swiftlint:disable:next force_unwrapping
        for searchEndpoint in searchTarget! {
            if let endpoint = searchEndpoint as? WrappedStruct, endpoint.id == id {
                return endpoint
            }
        }
        return nil
    }

    /// Retrieves all models from CodeStore
    /// - Parameter searchInCurrent: from current api (default) or previous facade
    /// - Returns: List of all models
    func getModels(searchInCurrent: Bool = true) -> [Modifiable] {
        guard guardSearchAccess(searchInCurrent) else {
            fatalError("Tried to search in previous facade which is not initialized.")
        }
        let modifiables = searchInCurrent ? currentAPI : previousFacade
        // Safety ensured by `guardSearchAccess()`
        // swiftlint:disable:next force_unwrapping
        return modifiables!.filter { ($0 as? WrappedClass) != nil }
    }

    /// Retrieves all endpoints from CodeStore
    /// - Parameter searchInCurrent: from current api (default) or previous facade
    /// - Returns: List of all endpoints
    func getEndpoints(searchInCurrent: Bool = true) -> [Modifiable] {
        guard guardSearchAccess(searchInCurrent) else {
            fatalError("Tried to search in previous facade which is not initialized.")
        }
        let modifiables = searchInCurrent ? currentAPI : previousFacade
        // Safety ensured by `guardSearchAccess()`
        // swiftlint:disable:next force_unwrapping
        return modifiables!.filter { ($0 as? WrappedStruct) != nil }
    }

    /// Retrieves all enums from CodeStore
    /// - Parameter searchInCurrent: from current api (default) or previous facade
    /// - Returns: List of all enums
    func getEnums(searchInCurrent: Bool = true) -> [Modifiable] {
        guard guardSearchAccess(searchInCurrent) else {
            fatalError("Tried to search in previous facade which is not initialized.")
        }
        let modifiables = searchInCurrent ? currentAPI : previousFacade
        // Safety ensured by `guardSearchAccess()`
        // swiftlint:disable:next force_unwrapping
        return modifiables!.filter { modifiable in
            guard let wrappedEnum = modifiable as? WrappedEnum,
                  wrappedEnum.localName.removePrefix != "OpenAPIError" else {
                return false
            }
            return true
        }
    }
    
    fileprivate func guardSearchAccess(_ searchInCurrent: Bool) -> Bool {
         (searchInCurrent || previousFacade != nil)
    }
}
