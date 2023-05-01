//
//  MobileContentApiRequest.swift
//  godtools
//
//  Created by Levi Eggert on 4/28/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RequestOperation

struct MobileContentApiRequest {
    
    let path: String
    let method: RequestMethod
    let headers: MobileContentApiUrlRequestHeaders
    let httpBody: [String: Any]?
    let queryItems: [URLQueryItem]?
}
