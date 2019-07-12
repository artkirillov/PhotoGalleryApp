//
//  User.swift
//  Look At This
//
//  Created by Artem Kirillov on 12/07/2019.
//

import Foundation

struct User: Codable {
    
    // MARK: - Public Properties
    
    let name: String
    
    // MARK: - Public Nested
    
    private enum CodingKeys: String, CodingKey {
        case name
    }
    
}

