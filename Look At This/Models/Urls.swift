//
//  Urls.swift
//  Look At This
//
//  Created by Artem Kirillov on 12/07/2019.
//

import Foundation

struct Urls: Codable {
    
    // MARK: - Public Properties
    
    let regular: String
    let thumb: String
    
    // MARK: - Public Nested
    
    private enum CodingKeys: String, CodingKey {
        case regular
        case thumb
    }
    
}
