//
//  ContentType.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

/// Abstract content type
class ContentType : Decodable {
    /// identifier of content type (e.g. name)
    var id : String?
}
