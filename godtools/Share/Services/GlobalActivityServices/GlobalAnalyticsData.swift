//
//  GlobalAnalyticsData.swift
//  godtools
//
//  Created by Levi Eggert on 2/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct GlobalAnalyticsData: Codable {
    
    let id: String
    let type: String
    let attributes: GlobalAnalyticsDataAttributes
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case attributes = "attributes"
    }
}
