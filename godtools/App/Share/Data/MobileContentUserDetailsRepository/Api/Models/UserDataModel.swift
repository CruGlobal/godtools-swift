//
//  UserDataModel.swift
//  godtools
//
//  Created by Rachael Skeath on 11/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct UserDataModel: Decodable {
    
    let id: String
    let createdAt: Date?
    
    enum RootKeys: String, CodingKey {
        case data
    }
    
    enum DataKeys: String, CodingKey {
        case id
        case attributes
    }
    
    enum AttributesKeys: String, CodingKey {
        case createdAt = "created-at"
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: RootKeys.self)
        let dataContainer = try container.nestedContainer(keyedBy: DataKeys.self, forKey: .data)
        
        id = try dataContainer.decode(String.self, forKey: .id)
        
        let attributesContainer = try dataContainer.nestedContainer(keyedBy: AttributesKeys.self, forKey: .attributes)
        
        let createdAtDateString = try attributesContainer.decodeIfPresent(String.self, forKey: .createdAt) ?? ""
        createdAt = UserDataModel.parseCreatedAtDateFromString(createdAtDateString)
    }
    
    private static func parseCreatedAtDateFromString(_ dateString: String) -> Date? {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [
            .withInternetDateTime
        ]
        
        return dateFormatter.date(from: dateString)
    }
}
