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
        get {
            let folder = self.lastComponent
            var persPath = self.parent()
            persPath = persPath + Path("Persistent" + folder)
            
            if !persPath.exists {
                try! persPath.mkdir()
            }
            
            return persPath
        }
    }
}
