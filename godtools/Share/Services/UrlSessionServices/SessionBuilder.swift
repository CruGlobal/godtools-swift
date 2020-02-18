//
//  SessionBuilder.swift
//  godtools
//
//  Created by Levi Eggert on 2/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class SessionBuilder {
    
    required init() {
        
    }
    
    func buildIgnoringCacheSession(timeoutIntervalForRequest: TimeInterval = 60) -> URLSession {
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        configuration.urlCache = nil
        
        configuration.httpCookieAcceptPolicy = HTTPCookie.AcceptPolicy.never
        configuration.httpShouldSetCookies = false
        configuration.httpCookieStorage = nil
        
        configuration.timeoutIntervalForRequest = timeoutIntervalForRequest
        
        return URLSession(configuration: configuration)
    }
}
