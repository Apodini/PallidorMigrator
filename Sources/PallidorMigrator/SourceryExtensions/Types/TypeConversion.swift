//
//  TypeConversion.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

/// Helper for converting types for en-/decoding
enum TypeConversion {
    /// Provides conversion string for type
    /// - Parameter from: type which needs to be converted
    /// - Returns: conversion string
    static func toString(data from: String) -> String {
        "String(data: \(from), encoding: .utf8)!"
    }

    /// Provides encoding string
    /// - Parameters:
    ///   - id: name of variable
    ///   - type: type of variable
    ///   - required: true if variable is required
    /// - Returns: Encoding string
    static func getEncodingString(id: String, type: String, required: Bool) -> String {
        if type.isPrimitiveType && !type.isCollectionType {
            return "String(\(id)\(required ? "" : "!"))"
        }

        if type.isPrimitiveType {
            return "JSONEncoder().encode(\(id))"
        }

        /// complex objects (wether in collection or not) need to conform to `Codable`
        return "try! JSONEncoder().encode(\(id))"
    }

    /// Provides decoding string
    /// - Parameters:
    ///   - id: name of variable
    ///   - type: type of variable
    /// - Returns: Decoding string
    static func getDecodingString(id: String, type: String) -> String {
        guard !type.isString else {
            return "\(id)!"
        }

        if type.isPrimitiveType && !type.isCollectionType {
            return "\(type.unwrapped.upperFirst)(\(id)!)!"
        }

        return "try! JSONDecoder().decode(\(type.unwrapped).self, from: \(id)!.data(using: .utf8)!)"
    }

    /// Get initializer string for default values.
    /// - Parameters:
    ///   - type: type of default value
    ///   - defaultValue: defaullt value string (e.g. JSON if complex)
    /// - Returns: initializer string
    static func getDefaultValueInit(type: String, defaultValue: String) -> String {
        if type.isDouble || type.isInteger {
            return "\(defaultValue)"
        }

        if type.isCollectionType || !type.isPrimitiveType {
            return """
            (try! JSONDecoder().decode(\(type.unwrapped).self, from: "\(defaultValue)".data(using: .utf8)!))
            """
        }

        return "\"\(defaultValue)\""
    }
}
