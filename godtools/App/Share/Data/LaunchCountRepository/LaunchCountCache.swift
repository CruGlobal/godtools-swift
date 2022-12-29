//
//  LaunchCountCache.swift
//  godtools
//
//  Created by Levi Eggert on 8/16/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class LaunchCountCache {
    
    private let userDefaults: UserDefaults = UserDefaults.standard
    
    init() {
        
    }
    
    func getLaunchCountPublisher() -> AnyPublisher<Int, Never> {
        
        return userDefaults.publisher(for: \.launchCount)
            .eraseToAnyPublisher()
    }
    
    func getLaunchCountValue() -> Int {
        
        return userDefaults.launchCount
    }
    
    func storeLaunchCount(launchCount: Int) {
        
        userDefaults.launchCount = launchCount
    }
}

private extension UserDefaults {
    
    private static let launchCountCacheKey: String = "LaunchCountCache.launchCountCacheKey"
    
    @objc dynamic var launchCount: Int {
        get {
            
            if object(forKey: UserDefaults.launchCountCacheKey) as? Int == nil {
                return 0
            }
            
            return integer(forKey: UserDefaults.launchCountCacheKey)
        }
        set {
            set(newValue, forKey: UserDefaults.launchCountCacheKey)
            synchronize()
        }
    }
}
