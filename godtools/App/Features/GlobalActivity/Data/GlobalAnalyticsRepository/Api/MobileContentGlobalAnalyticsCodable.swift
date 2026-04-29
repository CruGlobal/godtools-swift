//
//  MobileContentGlobalAnalyticsCodable.swift
//  godtools
//
//  Created by Levi Eggert on 1/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct MobileContentGlobalAnalyticsCodable: Codable, Sendable {
    
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
    
    init(id: String, countries: Int, gospelPresentations: Int, launches: Int, type: String, users: Int) {
        
        self.id = id
        self.countries = countries
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
    
    func copy(id: String?) -> MobileContentGlobalAnalyticsCodable {
        return MobileContentGlobalAnalyticsCodable(
            id: id ?? self.id,
            countries: countries,
            gospelPresentations: gospelPresentations,
            launches: launches,
            type: type,
            users: users
        )
    }
}

extension MobileContentGlobalAnalyticsCodable {
    
    func toModel() -> GlobalAnalyticsDataModel {
        return GlobalAnalyticsDataModel(
            id: id,
            createdAt: Date(),
            countries: countries,
            gospelPresentations: gospelPresentations,
            launches: launches,
            users: users,
            type: type
        )
    }
}
