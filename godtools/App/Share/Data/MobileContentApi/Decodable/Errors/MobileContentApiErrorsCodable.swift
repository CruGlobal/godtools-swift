//
//  MobileContentApiErrorsCodable.swift
//  godtools
//
//  Created by Levi Eggert on 9/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct MobileContentApiErrorsCodable: Codable {
    
    let errors: [MobileContentApiErrorCodable]
    
    enum RootKeys: String, CodingKey {
        case errors = "errors"
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: RootKeys.self)
        
        errors = try container.decode([MobileContentApiErrorCodable].self, forKey: .errors)
    }
}
