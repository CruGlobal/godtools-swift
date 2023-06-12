//
//  UserCounterDecodable.swift
//  godtools
//
//  Created by Rachael Skeath on 11/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct UserCounterDecodable: Codable {
    
    let id: String
    let count: Int
    
    enum RootKeys: String, CodingKey {
        case id
        case attributes
    }
    
    enum AttributesKeys: String, CodingKey {
        case count
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: RootKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        
        let attributesContainer = try container.nestedContainer(keyedBy: AttributesKeys.self, forKey: .attributes)
        
        count = try attributesContainer.decode(Int.self, forKey: .count)
    }
}
