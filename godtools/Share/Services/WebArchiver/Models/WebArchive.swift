//
//  WebArchive.swift
//  godtools
//
//  Created by Igor Ostriz, based on work by Ernesto Elsäßer and BiblioArchiver
//  Copyright © 2018 Cru. All rights reserved.
//


import Foundation

struct WebArchive: Encodable {
    
    let mainResource: WebArchiveMainResource
    var webSubresources: [WebArchiveResource]
    
    enum CodingKeys: String, CodingKey {
        case mainResource = "WebMainResource"
        case webSubresources = "WebSubresources"
    }
    
    init(resource: WebArchiveResource) {
        mainResource = WebArchiveMainResource(baseResource: resource)
        webSubresources = []
    }
    
    mutating func addSubresource(_ subresource: WebArchiveResource) {
        webSubresources.append(subresource)
    }
}
