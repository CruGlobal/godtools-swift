//
//  IncomingDeepLinkUrl.swift
//  godtools
//
//  Created by Levi Eggert on 6/28/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class IncomingDeepLinkUrl {
    
    let url: URL
    let pathComponents: [String]
    let rootPath: String?
    let queryParameters: [String: Any]
    
    required init(url: URL) {
        
        self.url = url
        self.pathComponents = url.pathComponents.filter({$0 != "/"})
        self.rootPath = pathComponents.first
        self.queryParameters = IncomingDeepLinkUrl.getJsonFromUrlQuery(url: url)
    }
    
    private static func getJsonFromUrlQuery(url: URL) -> [String: Any] {
        
        let components: URLComponents? = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems: [URLQueryItem] = components?.queryItems ?? []
        
        var queryParameters: [String: Any] = Dictionary()
        
        for queryItem in queryItems {
            queryParameters[queryItem.name] = queryItem.value
        }
        
        return queryParameters
    }
}
