//
//  SharedIgnoreCacheSession.swift
//  godtools
//
//  Created by Levi Eggert on 6/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

@available(*, deprecated) // TODO: Will be replaced with Common/URLSession/IgnoreCacheSession. GT-1727 ~Levi
class SharedIgnoreCacheSession: SharedSessionType {
    
    let session: URLSession
    
    required init() {
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        configuration.urlCache = nil
        
        configuration.httpCookieAcceptPolicy = HTTPCookie.AcceptPolicy.never
        configuration.httpShouldSetCookies = false
        configuration.httpCookieStorage = nil
        
        configuration.timeoutIntervalForRequest = 60
            
        session = URLSession(configuration: configuration)
    }
}
