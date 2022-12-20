//
//  GetUserCountersResponse.swift
//  godtools
//
//  Created by Rachael Skeath on 11/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct GetUserCountersResponse: Decodable {
    
    let userCounters: [UserCounterDecodable]
    
    enum RootKeys: String, CodingKey {
        case data
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: RootKeys.self)
        
        userCounters = try container.decode([UserCounterDecodable].self, forKey: .data)
    }
}
