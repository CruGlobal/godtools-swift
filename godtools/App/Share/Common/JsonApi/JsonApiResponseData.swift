//
//  JsonApiResponseData.swift
//  godtools
//
//  Created by Levi Eggert on 1/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct JsonApiResponseData<T: Decodable>: Decodable {
    
    let data: T
    
    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
}
