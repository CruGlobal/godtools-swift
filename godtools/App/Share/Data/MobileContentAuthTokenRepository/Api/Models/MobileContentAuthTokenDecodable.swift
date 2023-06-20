//
//  MobileContentAuthTokenDecodable.swift
//  godtools
//
//  Created by Rachael Skeath on 11/1/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct MobileContentAuthTokenDecodable: Codable {
    
    let token: String
    let expirationDate: Date?
    let userId: String
    let appleRefreshToken: String?
    
    enum DataKeys: String, CodingKey {
        case attributes
    }
    
    enum AttributesKeys: String, CodingKey {
        case token
        case expiration
        case userId = "user-id"
        case appleRefreshToken = "apple-refresh-token"
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: DataKeys.self)
        
        let attributesContainer = try container.nestedContainer(keyedBy: AttributesKeys.self, forKey: .attributes)
        
        token = try attributesContainer.decode(String.self, forKey: .token)
        let userIdInt = try attributesContainer.decode(Int.self, forKey: .userId)
        userId = String(userIdInt)
        
        let expirationDateString = try attributesContainer.decodeIfPresent(String.self, forKey: .expiration) ?? ""
        expirationDate = MobileContentAuthTokenDecodable.parseExpirationDateFromString(expirationDateString)
        
        appleRefreshToken = try attributesContainer.decodeIfPresent(String.self, forKey: .appleRefreshToken)
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
