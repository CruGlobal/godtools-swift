//
//  ActionCableEventType.swift
//  godtools
//
//  Created by Levi Eggert on 8/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct ActionCableEventType: Codable {
    
    let type: String?
    
    enum RootKeys: String, CodingKey {
        
        case type = "type"
    }
    
    init(from decoder: Decoder) throws {
                
        let container = try decoder.container(keyedBy: RootKeys.self)
        
        type = try container.decodeIfPresent(String.self, forKey: .type)
    }
}
