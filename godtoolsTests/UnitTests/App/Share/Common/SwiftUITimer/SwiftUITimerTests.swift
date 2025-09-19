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
        
        var cancellables: Set<AnyCancellable> = Set()
        
        let timer = SwiftUITimer(intervalSeconds: 0.1, repeats: false)
        
        var sinkCount: Int = 0
        
        await confirmation(expectedCount: 1) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    continuation.resume(returning: ())
                }
                
                timer
                    .startPublisher()
                    .sink { _ in
                        confirmation()
                        
                        sinkCount += 1
                        
                        if sinkCount == 1 {
                            timeoutTask.cancel()
                            continuation.resume(returning: ())
                        }
                    }
                    .store(in: &cancellables)
            }
        }
        
        #expect(timer.isRunning == false)
    }
    
    @Test("")
    @MainActor func timerRunsOnce() async {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        let timer = SwiftUITimer(intervalSeconds: 0.1, repeats: false)
        
        var sinkCount: Int = 0
        
        await confirmation(expectedCount: 1) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    continuation.resume(returning: ())
                }
                
                timer.start()
                
                timer
                    .publisher
                    .sink { _ in
                        confirmation()
                        
                        sinkCount += 1
                        
                        if sinkCount == 1 {
                            timeoutTask.cancel()
                            continuation.resume(returning: ())
                        }
                    }
                    .store(in: &cancellables)
            }
        }
        
        #expect(timer.isRunning == false)
    }
    
    @Test("")
    @MainActor func timerRunsUntilStopped() async {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        let timer = SwiftUITimer(intervalSeconds: 0.1, repeats: true)
        
        let maxTimerCount: Int = 3
        
        var sinkCount: Int = 0
        
        await confirmation(expectedCount: maxTimerCount) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    continuation.resume(returning: ())
                }
                
                timer
                    .startPublisher()
                    .sink { _ in
                        confirmation()
                        
                        sinkCount += 1
                        
                        if sinkCount == maxTimerCount {
                            timer.stop()
                            timeoutTask.cancel()
                            continuation.resume(returning: ())
                        }
                    }
                    .store(in: &cancellables)
            }
        }
        
        #expect(timer.isRunning == false)
    }
}
