//
//  ResourceModelMetatoolData.swift
//  godtools
//
//  Created by Levi Eggert on 6/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct ResourceModelMetatoolData: Decodable {
    
    let id: String
    let type: String
    
    enum RootKeys: String, CodingKey {
        case id = "id"
        case type = "type"
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: RootKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(String.self, forKey: .type)
    }
}
