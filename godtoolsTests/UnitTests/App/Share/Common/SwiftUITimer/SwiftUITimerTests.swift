//
//  SwiftUITimerTests.swift
//  godtools
//
//  Created by Levi Eggert on 8/11/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Combine

struct SwiftUITimerTests {
    
    @Test
    @MainActor func timerStartPublisherRunsOnce() async throws {
                
        let timer = SwiftUITimer(intervalSeconds: 0.1, repeats: false)
        
        _ = try await timer
            .startPublisher()
            .awaitFirstValue()
        
        #expect(timer.isRunning == false)
    }
    
    @Test
    @MainActor func timerRunsUntilStopped() async throws {
                
        let timer = SwiftUITimer(intervalSeconds: 0.1, repeats: true)
        
        let maxTimerCount: Int = 3
        
        _ = try await timer
            .startPublisher()
            .awaitValues(count: maxTimerCount)
        
        #expect(timer.isRunning == true)
        
        timer.stop()
        
        #expect(timer.isRunning == false)
    }
}
