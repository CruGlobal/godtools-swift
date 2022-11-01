//
//  MobileContentAuthTokenDataModel.swift
//  godtools
//
//  Created by Rachael Skeath on 11/1/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct MobileContentAuthTokenDataModel: Decodable {
    
    let token: String
    let expirationDate: String
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
        
        token = try attributesContainer.decodeIfPresent(String.self, forKey: .token) ?? ""
        expirationDate = try attributesContainer.decodeIfPresent(String.self, forKey: .expiration) ?? ""
        userId = try attributesContainer.decodeIfPresent(String.self, forKey: .userId) ?? ""
    }
}
