//
//  ResourceCacheValidation.swift
//  godtools
//
//  Created by Levi Eggert on 5/19/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ResourceCacheValidation {
        
    required init() {
        
    }
    
    private var defaults: UserDefaults {
        return UserDefaults.standard
    }
    
    private func getCacheKey(godToolsResource: GodToolsResource) -> String {
        return String(describing: ResourceCacheValidation.self) + "." + godToolsResource.resourceId + "." + godToolsResource.languageCode
    }
    
    private func cacheDateKey(godToolsResource: GodToolsResource) -> String {
        return getCacheKey(godToolsResource: godToolsResource) + ".cacheDate"
    }
    
    private func cacheVersionKey(godToolsResource: GodToolsResource) -> String {
        return getCacheKey(godToolsResource: godToolsResource) + ".translationVersion"
    }
    
    private func cachedDate(godToolsResource: GodToolsResource) -> Date? {
        return defaults.object(forKey: cacheDateKey(godToolsResource: godToolsResource)) as? Date
    }
    
    private func cachedVersion(godToolsResource: GodToolsResource) -> NSNumber? {
        return defaults.object(forKey: cacheVersionKey(godToolsResource: godToolsResource)) as? NSNumber
    }
    
    func setResourceCached(godToolsResource: GodToolsResource) {
                               
        let cacheDate: Date = Date()

        defaults.set(cacheDate, forKey: cacheDateKey(godToolsResource: godToolsResource))
        defaults.set(NSNumber(value: godToolsResource.translationsVersion), forKey: cacheVersionKey(godToolsResource: godToolsResource))
        
        defaults.synchronize()
    }
    
    func cachedResourceIsInvalid(godToolsResource: GodToolsResource, cacheExpirationSeconds: TimeInterval?) -> Bool {
                    
        guard let cacheDate = cachedDate(godToolsResource: godToolsResource) else {
            return true
        }
        
        guard let cacheVersion = cachedVersion(godToolsResource: godToolsResource) else {
            return true
        }
        
        let isExpired: Bool
        
        if let cacheExpirationSeconds = cacheExpirationSeconds {
            
            let timeSinceLastCacheDate: TimeInterval = Date().timeIntervalSince(cacheDate)
            isExpired = timeSinceLastCacheDate >= cacheExpirationSeconds
        }
        else {
            isExpired = false
        }
        
        
        let versionChanged: Bool = cacheVersion.int16Value != godToolsResource.translationsVersion
        
        return isExpired || versionChanged
    }
}
