//
//  Photo.swift
//  Look At This
//
//  Created by Artem Kirillov on 12/07/2019.
//

import Foundation

struct Photo: Codable {
    
    // MARK: - Public Properties
    
    let id: String
    let user: User
    let urls: Urls
    
    // MARK: - Public Nested
    
    private enum CodingKeys: String, CodingKey {
        case id
        case user
        case urls
    }
    
}
