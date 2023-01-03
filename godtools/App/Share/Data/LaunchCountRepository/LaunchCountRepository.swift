//
//  LaunchCountRepository.swift
//  godtools
//
//  Created by Levi Eggert on 8/16/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class LaunchCountRepository {
    
    private let cache: LaunchCountCache
    
    init(cache: LaunchCountCache) {
        
        self.cache = cache
    }
    
    func incrementLaunchCount() {
        
        let launchCount: Int = cache.getLaunchCountValue()
        
        guard launchCount < Int.max else {
            return
        }
        
        let newLaunchCount: Int = launchCount + 1
        
        cache.storeLaunchCount(launchCount: newLaunchCount)
    }
    
    func getLaunchCount() -> Int {
        
        return cache.getLaunchCountValue()
    }
    
    func getLaunchCountPublisher() -> AnyPublisher<Int, Never> {
        
        return cache.getLaunchCountPublisher()
    }
}
