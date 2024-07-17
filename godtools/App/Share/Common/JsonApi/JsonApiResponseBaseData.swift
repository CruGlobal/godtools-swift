//
//  JsonApiResponseBaseData.swift
//  godtools
//
//  Created by Levi Eggert on 12/23/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct JsonApiResponseBaseData: Codable {
    
    let id: String
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
    }
}
