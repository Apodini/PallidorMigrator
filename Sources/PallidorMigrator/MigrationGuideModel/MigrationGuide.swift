//
//  MigrationGuide.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

/// represents the migration guide
class MigrationGuide: Decodable {
    /// textual summary of changes between versions
    var summary: String
    /// supported specification type
    var specType: SpecificationType
    /// supported service type
    var serviceType: ServiceType
    /// list of changes between versions
    var changes: [Change]
    /// previous version
    var versionFrom: SemanticVersion
    /// current version
    var versionTo: SemanticVersion

    private enum CodingKeys: String, CodingKey {
        case summary
        case changes
        case specType = "api-spec"
        case versionFrom = "from-version"
        case versionTo = "to-version"
        case serviceType = "api-type"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.summary = try container.decode(String.self, forKey: .summary)
        self.specType = try container.decode(SpecificationType.self, forKey: .specType)
        self.serviceType = try container.decode(ServiceType.self, forKey: .serviceType)
        self.versionFrom = SemanticVersion(versionString: try container.decode(String.self, forKey: .versionFrom))
        self.versionTo = SemanticVersion(versionString: try container.decode(String.self, forKey: .versionTo))

        self.changes = [Change]()

        var changesContainer = try container.nestedUnkeyedContainer(forKey: .changes)

        while !changesContainer.isAtEnd {
            if let value = try? changesContainer.decode(AddChange.self) {
                self.changes.append(value)
                continue
            }
            if let value = try? changesContainer.decode(RenameChange.self) {
                self.changes.append(value)
                continue
            }
            if let value = try? changesContainer.decode(DeleteChange.self) {
                self.changes.append(value)
                addDeleted(change: value)
                continue
            }
            if let value = try? changesContainer.decode(ReplaceChange.self) {
                self.changes.append(value)
                continue
            }
            if let value = try? changesContainer.decode(Change.self) {
                self.changes.append(value)
            }
        }
    }

    /// Identifies deleted items and prepares the facade for their deletion
    /// - Parameter change: change in which sth. was deleted
    private func addDeleted(change: DeleteChange) {
        var modifiable: Modifiable?
        switch change.object {
        case .endpoint(let endpoint):
            if case .signature = change.target {
                let codeStore = CodeStore.getInstance()
                modifiable = codeStore.getEndpoint(endpoint.route)
                codeStore.insertDeleted(modifiable: modifiable!)
            }
        case .model(let model):
            if case .signature = change.target {
                let codeStore = CodeStore.getInstance()
                modifiable = codeStore.getModel(model.name)
                codeStore.insertDeleted(modifiable: modifiable!)
            }
        case .enum(let enumModel):
            if case .signature = change.target {
                let codeStore = CodeStore.getInstance()
                modifiable = codeStore.getEnum(enumModel.enumName)
                codeStore.insertDeleted(modifiable: modifiable!)
            }
        case .method(let method):
            if case .signature = change.target {
                let codeStore = CodeStore.getInstance()
                modifiable = codeStore.getMethod(method.operationId)
                let endpoint = codeStore.getEndpoint(method.definedIn, searchInCurrent: true)
                guard let wrappedMethod = modifiable as? WrappedMethod else {
                    fatalError("Method is malformed - operation id might be invalid")
                }
                endpoint!.methods.append(wrappedMethod)
            }
        }

        if let modifiable = modifiable {
            modifiable.modify(change: change)
        }
    }
}

extension MigrationGuide {
    /// The set of migrations which result from this migration guide
    var migrationSet: MigrationSet {
        MigrationSet(guide: self)
    }
}
