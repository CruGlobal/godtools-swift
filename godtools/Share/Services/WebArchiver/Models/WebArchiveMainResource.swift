//
//  WebArchiveMainResource.swift
//  godtools
//
//  Created by Levi Eggert on 4/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct WebArchiveMainResource: Encodable {
    
    let baseResource: WebArchiveResource
    
    enum CodingKeys: String, CodingKey {
        case url = "WebResourceURL"
        case data = "WebResourceData"
        case mimeType = "WebResourceMIMEType"
        case textEncodingName = "WebResourceTextEncodingName"
        case frameName = "WebResourceFrameName"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(baseResource.url, forKey: .url)
        try container.encode(baseResource.data, forKey: .data)
        try container.encode(baseResource.mimeType, forKey: .mimeType)
        try container.encode("UTF-8", forKey: .textEncodingName)
        try container.encode("", forKey: .frameName)
    }
}
