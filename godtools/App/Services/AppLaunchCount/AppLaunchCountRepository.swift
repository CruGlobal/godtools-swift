//
//  AppLaunchCountRepository.swift
//  godtools
//
//  Created by Levi Eggert on 9/1/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class AppLaunchCountRepository {
    
    private let cache: AppLaunchCountUserDefaultsCache
    
    required init(cache: AppLaunchCountUserDefaultsCache) {
        
        self.cache = cache
    }
    
    func getAppLaunchCount() -> Int64 {
        
        return cache.getAppLaunchCount()
    }
    
    func incrementAppLaunchCount() {
        
        cache.incrementAppLaunchCount()
    }
}
