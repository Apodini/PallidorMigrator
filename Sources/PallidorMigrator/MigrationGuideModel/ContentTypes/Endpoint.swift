//
//  Endpoint.swift
//
//  Created by Andre Weinkoetz on 10/10/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

/// represents an endpoint content type
class Endpoint : ContentType {
    
    /// the route which identifies this endpoint
    var route : String

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.route = try container.decode(String.self, forKey: .route)
        
        try super.init(from: decoder)
        self.id = route

    }
    
    private enum CodingKeys : String, CodingKey {
        case route
    }
    
    
    /// Converts the route to the endpoint name used by facade
    /// - Parameter route: top level route which identifies the endpoint
    /// - Returns: endpoint name used by facade
    static func endpointName(from route: String) -> String {
        "\(String(route.dropFirst()).upperFirst)API"
    }
    
    /// Converts the endpoint name used by facade to its route
    /// - Parameter name: endpoint name used by facade
    /// - Returns: top level route which identifies the endpoint
    static func routeName(from name: String) -> String {
        "/\(name.lowerFirst)".replacingOccurrences(of: "API", with: "")
    }
    
}
