//
//  LaunchCountCacheTests.swift
//  godtools
//
//  Created by Levi Eggert on 3/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Testing
@testable import godtools
import Combine

struct LaunchCountCacheTests {

    init() {
        
    }
    
    @Test()
    func initialLaunchCountShouldBeZero() async {
        
        let cache = getLaunchCountCache()
        
        #expect(cache.getLaunchCountValue() == 0)
    }
    
    @Test()
    func storingNewLaunchCount() async {
        
        let cache = getLaunchCountCache()
        
        #expect(cache.getLaunchCountValue() == 0)
        
        cache.storeLaunchCount(launchCount: 3)
        
        #expect(cache.getLaunchCountValue() == 3)
    }
    
    @Test()
    func launchCountPublisherTriggers() async {
        
        let cache = getLaunchCountCache()
        
        var cancellables: Set<AnyCancellable> = Set()
        var triggerCount: Int = 0
        var launchCountRef: Int = 0
        
        let expectedTriggerCount: Int = 4
        let expectedLaunchCount: Int = 7
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            cache
                .getLaunchCountChangedPublisher()
                .sink { (count: Int) in
                    
                    launchCountRef = count
                    
                    triggerCount += 1
                    
                    let completed: Bool = triggerCount == expectedTriggerCount
                    
                    if completed {
                        // When finished be sure to call:
                        timeoutTask.cancel()
                        continuation.resume(returning: ())
                    }
                }
                .store(in: &cancellables)
            
            cache.storeLaunchCount(launchCount: 1)
            cache.storeLaunchCount(launchCount: 5)
            cache.storeLaunchCount(launchCount: 7)
        }
        
        #expect(launchCountRef == expectedLaunchCount)
    }
}

extension LaunchCountCacheTests {
    
    private func getLaunchCountCache() -> LaunchCountCache {
        let cache = LaunchCountCache()
        cache.resetLaunchCount()
        return cache
    }
}
