//
//  FileManager+SwiftFilter.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

extension FileManager {
    /// Returns a list of all file names inside a directory
    /// - Parameter path: path string of directory
    /// - Throws: error if path does not exist
    /// - Returns: list of all file names
    open func swiftFilesInDirectory(atPath path: String) throws -> [String] {
        let filePaths = try FileManager.default.contentsOfDirectory(atPath: path)
        return filePaths.filter { $0.contains(".swift") }
    }
}
