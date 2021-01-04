//
//  Path+Persistent.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation
import PathKit

extension Path {
    /// returns the persistent variant of the current path
    public var persistentPath: Path {
            let folder = self.lastComponent
            let persPath = self.parent() + Path("Persistent" + folder)

            if !persPath.exists {
                do {
                    try persPath.mkdir()
                } catch {
                    fatalError("Failed to create directory at \(persPath.string)")
                }
            }
            return persPath
    }
}
