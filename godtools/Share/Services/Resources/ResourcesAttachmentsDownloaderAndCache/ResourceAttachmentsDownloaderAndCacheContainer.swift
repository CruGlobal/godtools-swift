//
//  ResourceAttachmentsDownloaderAndCacheContainer.swift
//  godtools
//
//  Created by Levi Eggert on 6/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ResourceAttachmentsDownloaderAndCacheContainer: NSObject {
    
    private let resourcesFileCache: ResourcesSHA256FilesCache
    private let resourcesCache: ResourcesRealmCache
    private let session: URLSession
    
    private var resourceAttachmentsDownloaderAndCacheObjects: [String: ResourceAttachmentsDownloaderAndCache] = Dictionary()
    
    required init(resourcesFileCache: ResourcesSHA256FilesCache, resourcesCache: ResourcesRealmCache) {
        
        self.resourcesFileCache = resourcesFileCache
        self.resourcesCache = resourcesCache
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        configuration.urlCache = nil
        
        configuration.httpCookieAcceptPolicy = HTTPCookie.AcceptPolicy.never
        configuration.httpShouldSetCookies = false
        configuration.httpCookieStorage = nil
        
        configuration.timeoutIntervalForRequest = 20
            
        session = URLSession(configuration: configuration)
        
        super.init()
    }
    
    func downloadAndCacheResourcesAttachments(resources: [RealmResource]) {
             
        print("\n BEGIN DOWNLOADING ATTACHMENTS")
        
        for resource in resources {
            
            let resourceAttachmentsDownloaderAndCache = getResourceAttachmentsDownloaderAndCache(resouceId: resource.id)
                        
            resourceAttachmentsDownloaderAndCache.downloadAndCacheAttachments(resource: resource)
        }
    }
    
    func getResourceAttachmentsDownloaderAndCache(resouceId: String) -> ResourceAttachmentsDownloaderAndCache {
        
        if let resourceAttachmentsDownloaderAndCache = resourceAttachmentsDownloaderAndCacheObjects[resouceId] {
            
            return resourceAttachmentsDownloaderAndCache
        }
        else {
            
            let resourceAttachmentsDownloaderAndCache =  ResourceAttachmentsDownloaderAndCache(
                session: session,
                resourcesFileCache: resourcesFileCache,
                resourcesCache: resourcesCache
            )
            
            resourceAttachmentsDownloaderAndCacheObjects[resouceId] = resourceAttachmentsDownloaderAndCache
            
            return resourceAttachmentsDownloaderAndCache
        }
    }
}
