//
//  MobileContentApiErrorCodable.swift
//  godtools
//
//  Created by Levi Eggert on 9/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct MobileContentApiErrorCodable: Codable {
    
    let code: String
    let detail: String
    
    enum RootKeys: String, CodingKey {
        case code = "code"
        case detail = "detail"
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: RootKeys.self)
        
        code = try container.decode(String.self, forKey: .code)
        detail = try container.decode(String.self, forKey: .detail)
    }
}
