//
//  MobileContentGlobalAnalyticsDecodable.swift
//  godtools
//
//  Created by Levi Eggert on 1/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct MobileContentGlobalAnalyticsDecodable: Codable {
    
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
    
    static func createEmpty() -> MobileContentGlobalAnalyticsDecodable {
        return MobileContentGlobalAnalyticsDecodable(countries: 0, id: "", gospelPresentations: 0, launches: 0, type: "", users: 0)
    }
    
    init(countries: Int, id: String, gospelPresentations: Int, launches: Int, type: String, users: Int) {
        
        self.countries = countries
        self.id = id
        self.gospelPresentations = gospelPresentations
        self.launches = launches
        self.type = type
        self.users = users
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
