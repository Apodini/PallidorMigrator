//
//  String+PrimitiveCheck.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

extension String {
    /// returns true if the type defined in this string matches the regex pattern of a primitive type in Swift
    public var isPrimitiveType: Bool {
        try! !NSRegularExpression(pattern: #"\[?((String|Int(32|64)?|Double|Bool|Date):)?(String|Int(32|64)?|Double|Bool|Date)\]?\??"#).matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)).isEmpty
    }
    
    /// returns true if the type defined in this string matches the regex pattern of an integer type in Swift
    public var isInteger: Bool {
        try! !NSRegularExpression(pattern: #"^Int(32|64)?$"#).matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)).isEmpty
    }
    
    /// returns true if the type defined in this string matches the regex pattern of a boolean type in Swift
    public var isBool: Bool {
        try! !NSRegularExpression(pattern: #"^Bool$"#).matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)).isEmpty
    }
    
    /// returns true if the type defined in this string matches the regex pattern of a double type in Swift
    public var isDouble: Bool {
        try! !NSRegularExpression(pattern: #"^Double$"#).matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)).isEmpty
    }
    
    /// returns true if the type defined in this string matches the regex pattern of a string type in Swift
    public var isString: Bool {
        try! !NSRegularExpression(pattern: #"^String$"#).matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)).isEmpty
    }
    
    /// returns true if the type defined in this string matches the regex pattern of an array type in Swift
    public var isArrayType: Bool {
        try! !NSRegularExpression(pattern: #"^\[\w+\]$"#).matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)).isEmpty
    }
    
    /// returns true if the type defined in this string matches the regex pattern of a dictionary type in Swift
    public var isDictionaryType: Bool {
        try! !NSRegularExpression(pattern: #"^\[\w+:\w+\]$"#).matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)).isEmpty
    }
    
    /// returns true if the type defined in this string matches the regex pattern of a collection (array or dictionary) type in Swift
    public var isCollectionType: Bool {
        try! !NSRegularExpression(pattern: #"^\[\w+:?\w+\]$"#).matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)).isEmpty
    }
    
    /// returns true if the type defined in this string has a trailing `?`
    public var isOptional: Bool {
        self.last! == "?"
    }
    
    /// returns the type name without `?` if type is an optional
    public var unwrapped: String {
        self.isOptional ? String(self.dropLast()) : self
    }
    
    /// returns the type name with `?` if type is not already an optional
    public var wrapped: String {
        !self.isOptional ? "\(self)?" : self
    }
    
    /// returns the type of items inside an array
    public var itemType: String {
        unwrapped.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
    }
}
