//
//  GlobalAnalytics.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct GlobalAnalytics: Codable {
 
    let data: GlobalAnalytics.Data
    
    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
    
    struct Data: Codable {
        
        let id: String
        let type: String
        let attributes: GlobalAnalytics.Data.Attributes
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case type = "type"
            case attributes = "attributes"
        }
        
        struct Attributes: Codable {
            
            let users: Int
            let countries: Int
            let launches: Int
            let gospelPresentations: Int
            
            enum CodingKeys: String, CodingKey {
                case users = "users"
                case countries = "countries"
                case launches = "launches"
                case gospelPresentations = "gospel-presentations"
            }
        }
    }
}
