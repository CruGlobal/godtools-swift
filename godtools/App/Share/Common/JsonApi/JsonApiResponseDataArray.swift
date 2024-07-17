//
//  JsonApiResponseDataArray.swift
//  godtools
//
//  Created by Levi Eggert on 12/23/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct JsonApiResponseDataArray<T: Codable>: Codable {
    
    let dataArray: [T]
    
    enum CodingKeys: String, CodingKey {
        case dataArray = "data"
    }
}
