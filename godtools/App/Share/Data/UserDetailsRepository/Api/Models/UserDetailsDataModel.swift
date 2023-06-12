//
//  UserDetailsDataModel.swift
//  godtools
//
//  Created by Rachael Skeath on 11/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct UserDetailsDataModel: Codable {
    
    let id: String
    let createdAt: Date?
    
    enum DataKeys: String, CodingKey {
        case id
        case attributes
    }
    
    enum AttributesKeys: String, CodingKey {
        case createdAt = "created-at"
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: DataKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        
        let attributesContainer = try container.nestedContainer(keyedBy: AttributesKeys.self, forKey: .attributes)
        
        let createdAtDateString = try attributesContainer.decodeIfPresent(String.self, forKey: .createdAt) ?? ""
        createdAt = UserDetailsDataModel.parseCreatedAtDateFromString(createdAtDateString)
    }
    
    init(realmUserDetails: RealmUserDetails) {
        
        id = realmUserDetails.id
        createdAt = realmUserDetails.createdAt
    }
    
    private static func parseCreatedAtDateFromString(_ dateString: String) -> Date? {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [
            .withInternetDateTime
        ]
        
        return dateFormatter.date(from: dateString)
    }
}
