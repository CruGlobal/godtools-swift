//
//  ResourceAttachmentsServices.swift
//  godtools
//
//  Created by Levi Eggert on 6/16/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ResourceAttachmentsServices {
    
    typealias ResourceId = String
    
    private let session: URLSession
    private let resourcesCache: ResourcesCache
    
    private var services: [ResourceId: ResourceAttachmentsService] = Dictionary()
    
    required init(resourcesCache: ResourcesCache) {
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        configuration.urlCache = nil
        
        configuration.httpCookieAcceptPolicy = HTTPCookie.AcceptPolicy.never
        configuration.httpShouldSetCookies = false
        configuration.httpCookieStorage = nil
        
        configuration.timeoutIntervalForRequest = 20
            
        self.session = URLSession(configuration: configuration)
        self.resourcesCache = resourcesCache
    }
    
    func getResourceAttachmentsService(resourceId: String) -> ResourceAttachmentsService {
        
        if let service = services[resourceId] {
            return service
        }
        
        let newService =  ResourceAttachmentsService(
            session: session,
            resourcesCache: resourcesCache
        )
        
        services[resourceId] = newService
        
        return newService
    }
}
