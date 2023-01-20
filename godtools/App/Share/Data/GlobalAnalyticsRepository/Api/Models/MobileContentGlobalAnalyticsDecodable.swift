//
//  MobileContentGlobalAnalyticsDecodable.swift
//  godtools
//
//  Created by Levi Eggert on 1/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct MobileContentGlobalAnalyticsDecodable: Decodable {
    
    let countries: Int
    let id: String
    let gospelPresentations: Int
    let launches: Int
    let type: String
    let users: Int
    
    enum RootKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case attributes = "attributes"
    }
    
    enum AttributesKeys: String, CodingKey {
        case users = "users"
        case countries = "countries"
        case launches = "launches"
        case gospelPresentations = "gospel-presentations"
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: RootKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(String.self, forKey: .type)
        
        // attributes
        let attributesContainer = try container.nestedContainer(keyedBy: AttributesKeys.self, forKey: .attributes)
        
        countries = try attributesContainer.decode(Int.self, forKey: .countries)
        gospelPresentations = try attributesContainer.decode(Int.self, forKey: .gospelPresentations)
        launches = try attributesContainer.decode(Int.self, forKey: .launches)
        users = try attributesContainer.decode(Int.self, forKey: .users)
    }
}
