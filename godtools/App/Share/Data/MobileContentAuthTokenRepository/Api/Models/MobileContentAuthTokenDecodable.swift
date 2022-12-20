//
//  MobileContentAuthTokenDecodable.swift
//  godtools
//
//  Created by Rachael Skeath on 11/1/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct MobileContentAuthTokenDecodable: Decodable {
    
    let token: String
    let expirationDate: Date?
    let userId: String
    
    enum RootKeys: String, CodingKey {
        case data
    }
    
    enum DataKeys: String, CodingKey {
        case attributes
    }
    
    enum AttributesKeys: String, CodingKey {
        case token
        case expiration
        case userId = "user-id"
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: RootKeys.self)
        
        let dataContainer = try container.nestedContainer(keyedBy: DataKeys.self, forKey: .data)
        let attributesContainer = try dataContainer.nestedContainer(keyedBy: AttributesKeys.self, forKey: .attributes)
        
        token = try attributesContainer.decode(String.self, forKey: .token)
        let userIdInt = try attributesContainer.decode(Int.self, forKey: .userId)
        userId = String(userIdInt)
        
        let expirationDateString = try attributesContainer.decodeIfPresent(String.self, forKey: .expiration) ?? ""
        expirationDate = MobileContentAuthTokenDecodable.parseExpirationDateFromString(expirationDateString)
    }
    
    private static func parseExpirationDateFromString(_ dateString: String) -> Date? {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]
        
        return dateFormatter.date(from: dateString)
    }
}
