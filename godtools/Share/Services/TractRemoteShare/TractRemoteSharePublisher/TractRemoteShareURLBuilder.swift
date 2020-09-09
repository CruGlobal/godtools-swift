//
//  TractRemoteShareURLBuilder.swift
//  godtools
//
//  Created by Levi Eggert on 8/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

// Example url: https: //knowgod.com/de/kgp?icid=gtshare&primaryLanguage=en&parallelLanguage=de&liveShareStream=9cae02af93e1d510c3e0-1597355635

class TractRemoteShareURLBuilder {
    
    required init() {
        
    }
    
    func buildRemoteShareURL(resource: ResourceModel, primaryLanguage: LanguageModel, parallelLanguage: LanguageModel?, subscriberChannelId: String) -> String? {
        
        var urlComponents: URLComponents = URLComponents()
        
        urlComponents.scheme = "https"
        urlComponents.host = "knowgod.com"
        urlComponents.path = "/" + primaryLanguage.code + "/" + resource.abbreviation
        
        var queryItems: [URLQueryItem] = Array()
        if let parallelLanguage = parallelLanguage {
            queryItems.append(URLQueryItem(name: "parallelLanguage", value: parallelLanguage.code))
        }
        queryItems.append(URLQueryItem(name: "icid", value: "gtshare"))
        queryItems.append(URLQueryItem(name: "primaryLanguage", value: primaryLanguage.code))
        queryItems.append(URLQueryItem(name: "liveShareStream", value: subscriberChannelId))
        
        urlComponents.queryItems = queryItems
        
        return urlComponents.url?.absoluteString
    }
}
