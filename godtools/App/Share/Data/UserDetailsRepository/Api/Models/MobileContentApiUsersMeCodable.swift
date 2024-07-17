//
//  MobileContentApiUsersMeCodable.swift
//  godtools
//
//  Created by Levi Eggert on 8/10/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct MobileContentApiUsersMeCodable: Codable {
    
    let id: String
    let createdAt: Date?
    let familyName: String?
    let givenName: String?
    let name: String?
    let ssoGuid: String?
    let type: String
    
    enum RootKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case attributes = "attributes"
        case relationships = "relationships"
    }
    
    enum AttributesKeys: String, CodingKey {
        case createdAt = "created-at"
        case familyName = "family-name"
        case givenName = "given-name"
        case name = "name"
        case ssoGuid = "sso-guid"
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: RootKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(String.self, forKey: .type)
        
        var attributesContainer: KeyedDecodingContainer<AttributesKeys>?
        
        do {
            attributesContainer = try container.nestedContainer(keyedBy: AttributesKeys.self, forKey: .attributes)
        }
        catch {

        }
        
        if let createdAtString = try attributesContainer?.decodeIfPresent(String.self, forKey: .createdAt), !createdAtString.isEmpty {            
            createdAt = ISO8601DateFormatter().date(from: createdAtString)
        }
        else {
            createdAt = nil
        }
        
        familyName = try attributesContainer?.decodeIfPresent(String.self, forKey: .familyName)
        givenName = try attributesContainer?.decodeIfPresent(String.self, forKey: .givenName)
        name = try attributesContainer?.decodeIfPresent(String.self, forKey: .name)
        ssoGuid = try attributesContainer?.decodeIfPresent(String.self, forKey: .ssoGuid)
    }
}
