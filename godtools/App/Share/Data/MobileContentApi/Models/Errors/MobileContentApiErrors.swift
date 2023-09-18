//
//  MobileContentApiErrors.swift
//  godtools
//
//  Created by Levi Eggert on 9/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct MobileContentApiErrors: Codable {
    
    let errors: [MobileContentApiError]
    
    enum RootKeys: String, CodingKey {
        case errors = "errors"
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: RootKeys.self)
        
        errors = try container.decode([MobileContentApiError].self, forKey: .errors)
    }
}
