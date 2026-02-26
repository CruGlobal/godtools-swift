//
//  MobileContentAuthTokenDecodable.swift
//  godtools
//
//  Created by Rachael Skeath on 11/1/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct MobileContentAuthTokenDecodable: MobileContentAuthTokenDataModelInterface, Codable {
    
    let appleRefreshToken: String?
    let expirationDate: Date?
    let id: String
    let token: String
    let userId: String
    
    enum DataKeys: String, CodingKey {
        case attributes
    }
    
    enum AttributesKeys: String, CodingKey {
        case appleRefreshToken = "apple-refresh-token"
        case expiration
        case token
        case userId = "user-id"
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: DataKeys.self)
        
        let attributesContainer = try container.nestedContainer(keyedBy: AttributesKeys.self, forKey: .attributes)
        
        token = try attributesContainer.decode(String.self, forKey: .token)
        let userIdInt = try attributesContainer.decode(Int.self, forKey: .userId)
        userId = String(userIdInt)
        
        id = userId
        
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
