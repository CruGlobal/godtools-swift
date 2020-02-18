//
//  GlobalAnalyticsDataAttributes.swift
//  godtools
//
//  Created by Levi Eggert on 2/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct GlobalAnalyticsDataAttributes: Codable {
    
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
