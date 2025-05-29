//
//  CreateIgnoreCacheSessionConfig.swift
//  godtools
//
//  Created by Levi Eggert on 5/29/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class CreateIgnoreCacheSessionConfig: CreateUrlSessionConfigInterface {
    
    init() {
        
    }
    
    func createConfiguration(timeoutIntervalForRequest: TimeInterval = 60) -> URLSessionConfiguration {
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        configuration.urlCache = nil
        
        configuration.httpCookieAcceptPolicy = HTTPCookie.AcceptPolicy.never
        configuration.httpShouldSetCookies = false
        configuration.httpCookieStorage = nil
        
        configuration.timeoutIntervalForRequest = timeoutIntervalForRequest
        
        return configuration
    }
}
