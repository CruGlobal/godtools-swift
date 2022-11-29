//
//  IncrementUserCounterResponse.swift
//  godtools
//
//  Created by Rachael Skeath on 11/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct IncrementUserCounterResponse: Decodable {
    
    let userCounter: UserCounterDataModel
    
    enum RootKeys: String, CodingKey {
        case data
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: RootKeys.self)
        
        userCounter = try container.decode(UserCounterDataModel.self, forKey: .data)
    }
}
