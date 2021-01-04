//
//  MigrationSet.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

/// represents all migrations resulting from the migration guide
class MigrationSet {
    /// guide from which this set is generated
    private var guide: MigrationGuide
    /// list of migrations to be executed
    private var migrations: [Migrating]

    init(guide: MigrationGuide) {
        self.guide = guide
        self.migrations = [Migrating]()
    }

    /// Activates and executes all migrations according to changes from migration guide
    /// - Parameter modifiable: the modifiable which is about to be changed
    /// - Throws: error if change type could not be detected
    /// - Returns: the migrated modifiable
    func activate(for modifiable: Modifiable?) throws -> Modifiable {
        var migration: Migrating?
        for change in guide.changes {
            switch change.object {
            case .endpoint(let endpoint):
                if endpoint.route == modifiable!.id {
                    migration = createMigration(change: change, target: modifiable!)
                    migrations.append(migration!)
                }
            case .method(let method):
                if method.definedIn == modifiable!.id {
                    migration = createMigration(change: change, target: modifiable!)
                    migrations.append(migration!)
                }
            case .model(let model):
                if model.id == modifiable!.id {
                    migration = createMigration(change: change, target: modifiable!)
                    migrations.append(migration!)
                }

            case .enum(let enumModel):
                if enumModel.id == modifiable!.id {
                    migration = createMigration(change: change, target: modifiable!)
                    migrations.append(migration!)
                }
            }
        }

        for mig in migrations {
            try mig.execute()
        }

        return modifiable!
    }
    
    /// creates the migration required to adapt the modifiable
    /// - Parameters:
    ///   - change: change that affects modifiable
    ///   - target: modifiable
    /// - Returns: migration which adapts the modifiable according to changes
    private func createMigration(change: Change, target: Modifiable) -> Migrating {
        switch change.changeType {
        case .add:
            // solvable has to be checked on constraint conditions (aka. remove endpoint not supported)
            return AddMigration(solvable: true, executeOn: target, change: change)
        case .rename:
            // solvable has to be checked on constraint conditions (aka. remove endpoint not supported)
            return RenameMigration(solvable: true, executeOn: target, change: change)
        case .delete:
            return createDeleteMigration(change, target)
        case .replace:
            // solvable has to be checked on constraint conditions (aka. remove endpoint not supported)
            if case .method(let method) = change.object, case .signature = change.target, method.definedIn != target.id {
                let target = CodeStore.getInstance().getMethod(method.operationId)
                return ReplaceMigration(solvable: true, executeOn: target!, change: change)
            }
            return ReplaceMigration(solvable: true, executeOn: target, change: change)
        case .nil:
            fatalError("No change type detected")
        }
    }

    fileprivate func createDeleteMigration(_ change: Change, _ target: Modifiable) -> Migrating {
        if case .model(let method) = change.object, case .signature = change.target {
            let target = CodeStore.getInstance().getModel(method.name)!
            return DeleteMigration(solvable: true, executeOn: target, change: change)
        }
        if case .endpoint(let endpoint) = change.object, case .signature = change.target {
            let target = CodeStore.getInstance().getEndpoint(endpoint.id!)!
            return DeleteMigration(solvable: true, executeOn: target, change: change)
        }
        if case .enum(let targetEnum) = change.object {
            if case .signature = change.target {
                let target = CodeStore.getInstance().getEnum(targetEnum.id!)!
                return DeleteMigration(solvable: true, executeOn: target, change: change)
            }
            if case .case = change.target {
                let facade = CodeStore.getInstance().getEnum(targetEnum.id!)!
                guard let target = target as? WrappedEnum, let change = change as? DeleteChange else {
                    fatalError("Target is no enum or change type is malformed.")
                }
                target.cases.append(facade.cases.first(where: { $0.name == change.fallbackValue!.id! })!)
                return DeleteMigration(solvable: true, executeOn: target, change: change)
            }
        }
        return DeleteMigration(solvable: true, executeOn: target, change: change)
    }
}
