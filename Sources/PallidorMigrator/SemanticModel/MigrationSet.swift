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
                break
            case .method(let method):
                if method.definedIn == modifiable!.id {
                    migration = createMigration(change: change, target: modifiable!)
                    migrations.append(migration!)
                }
                break
            case .service:
                break
            case .model(let model):
                if model.id == modifiable!.id {
                    migration = createMigration(change: change, target: modifiable!)
                    migrations.append(migration!)
                }
                break
            case .enum(let enumModel):
                if enumModel.id == modifiable!.id {
                    migration = createMigration(change: change, target: modifiable!)
                    migrations.append(migration!)
                }
                break
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
            return AddMigration(solvable: true, executeOn: target, change: change as! AddChange)
        case .rename:
            // solvable has to be checked on constraint conditions (aka. remove endpoint not supported)
            return RenameMigration(solvable: true, executeOn: target, change: change as! RenameChange)
        case .delete:
            if case .model(let m) = change.object, case .signature = change.target {
                let target = CodeStore.getInstance().getModel(m.name)!
                return DeleteMigration(solvable: true, executeOn: target, change: change as! DeleteChange)
            }
            if case .endpoint(let e) = change.object, case .signature = change.target {
                let target = CodeStore.getInstance().getEndpoint(e.id!)!
                return DeleteMigration(solvable: true, executeOn: target, change: change as! DeleteChange)
            }
            if case .enum(let e) = change.object {
                if case .signature = change.target {
                    let target = CodeStore.getInstance().getEnum(e.id!)!
                    return DeleteMigration(solvable: true, executeOn: target, change: change as! DeleteChange)
                }
                if case .case = change.target {
                    let facade = CodeStore.getInstance().getEnum(e.id!)!
                    (target as! WrappedEnum).cases.append(facade.cases.first(where: { $0.name == (change as! DeleteChange).fallbackValue!.id! })!)
                    return DeleteMigration(solvable: true, executeOn: target, change: change as! DeleteChange)
                }
            }
            return DeleteMigration(solvable: true, executeOn: target, change: change as! DeleteChange)
        case .replace:
            // solvable has to be checked on constraint conditions (aka. remove endpoint not supported)
            if case .method(let m) = change.object, case .signature = change.target, m.definedIn != target.id {
                let target = CodeStore.getInstance().getMethod(m.operationId)
                return ReplaceMigration(solvable: true, executeOn: target!, change: change as! ReplaceChange)
            }
            return ReplaceMigration(solvable: true, executeOn: target, change: change as! ReplaceChange)
        case .nil:
            fatalError("No change type detected")
        }
    }
}
