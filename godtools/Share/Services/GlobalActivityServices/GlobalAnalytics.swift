//
//  GlobalAnalytics.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct GlobalAnalytics: Codable {
 
    let data: GlobalAnalyticsData
    
    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
}
