//
//  AppLaunchCountUserDefaultsCache.swift
//  godtools
//
//  Created by Levi Eggert on 9/1/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class AppLaunchCountUserDefaultsCache {
    
    private let userDefaultsCache: SharedUserDefaultsCache
    private let appLaunchCountCacheKey: String
    
    required init(userDefaultsCache: SharedUserDefaultsCache, appLaunchCountCacheKey: String) {
        
        self.userDefaultsCache = userDefaultsCache
        self.appLaunchCountCacheKey = appLaunchCountCacheKey
    }
    
    private func storeAppLaunchCount(appLaunchCount: Int64) {
        
        userDefaultsCache.cache(value: NSNumber(value: appLaunchCount), forKey: appLaunchCountCacheKey)
        userDefaultsCache.commitChanges()
    }
    
    func getAppLaunchCount() -> Int64 {
        
        let defaultLaunchCount: Int64 = 0
        
        guard let launchCount = userDefaultsCache.getValue(key: appLaunchCountCacheKey) as? NSNumber else {
            return defaultLaunchCount
        }
        
        return launchCount.int64Value
    }
    
    func incrementAppLaunchCount() {
        
        let currentAppLaunchCount: Int64 = getAppLaunchCount()
        
        guard currentAppLaunchCount < Int64.max else {
            return
        }
        
        let newAppLaunchCount: Int64 = currentAppLaunchCount + 1
        
        storeAppLaunchCount(appLaunchCount: newAppLaunchCount)
    }
}
