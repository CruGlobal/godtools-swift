//
//  ShareToolScreenTutorialNumberOfViewsCache.swift
//  godtools
//
//  Created by Levi Eggert on 8/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ShareToolScreenTutorialNumberOfViewsCache {
    
    private let sharedUserDefaultsCache: SharedUserDefaultsCache
    
    required init(sharedUserDefaultsCache: SharedUserDefaultsCache) {
        
        self.sharedUserDefaultsCache = sharedUserDefaultsCache
    }
    
    private func getKey(resource: ResourceModel) -> String {
        return "ShareToolScreenTutorialNumberOfViewsCache.resourceId.\(resource.id)"
    }
    
    func tutorialViewed(resource: ResourceModel) {
        
        let currentNumberOfViews: Int = getNumberOfViews(resource: resource)
        let numberOfViews: Int = currentNumberOfViews + 1
        
        sharedUserDefaultsCache.cache(value: NSNumber(value: numberOfViews), forKey: getKey(resource: resource))
        sharedUserDefaultsCache.commitChanges()
    }
    
    func getNumberOfViews(resource: ResourceModel) -> Int {
        
        if let views = sharedUserDefaultsCache.getValue(key: getKey(resource: resource)) as? NSNumber {
            return views.intValue
        }
        
        return 0
    }
}
