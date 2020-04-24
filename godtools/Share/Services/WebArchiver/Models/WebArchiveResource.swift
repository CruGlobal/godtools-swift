//
//  WebArchiveResponse.swift
//  godtools
//
//  Created by Levi Eggert on 4/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct WebArchiveResource: Encodable {
    
    let url: String
    let data: Data
    let mimeType: String
    
    enum CodingKeys: String, CodingKey {
        case url = "WebResourceURL"
        case data = "WebResourceData"
        case mimeType = "WebResourceMIMEType"
    }
}
