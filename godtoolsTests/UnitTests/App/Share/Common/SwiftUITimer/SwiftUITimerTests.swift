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
    
    @Test("")
    @MainActor func timerStartPublisherRunsOnce() async {
                
        let timer = SwiftUITimer(intervalSeconds: 0.1, repeats: false)
        
        var cancellables: Set<AnyCancellable> = Set()
        var triggerCount: Int = 0
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            timer
                .startPublisher()
                .sink { _ in
                    
                    triggerCount += 1
                    
                    if triggerCount == 1 {
                        
                        // When finished be sure to call:
                        timeoutTask.cancel()
                        continuation.resume(returning: ())
                    }
                }
                .store(in: &cancellables)
        }
        
        #expect(timer.isRunning == false)
    }
    
    @Test("")
    @MainActor func timerRunsUntilStopped() async {
                
        let timer = SwiftUITimer(intervalSeconds: 0.1, repeats: true)
        
        let maxTimerCount: Int = 3
        
        var cancellables: Set<AnyCancellable> = Set()
        var triggerCount: Int = 0
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            timer
                .startPublisher()
                .sink { _ in
                    
                    triggerCount += 1
                    
                    if triggerCount == maxTimerCount {
                        
                        timer.stop()
                        
                        // When finished be sure to call:
                        timeoutTask.cancel()
                        continuation.resume(returning: ())
                    }
                }
                .store(in: &cancellables)
        }
        
        #expect(timer.isRunning == false)
    }
}
