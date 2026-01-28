//
//  ProgressTimerTests.swift
//  godtools
//
//  Created by Levi Eggert on 8/11/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Combine
import Foundation

struct ProgressTimerTests {
    
    @Test("")
    func timerPublisherRunsForHalfSecond() async {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        let progressTimer = ProgressTimer()
        
        let halfSecond: TimeInterval = 0.5
                
        var progress: Double = 0
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
                continuation.resume(returning: ())
            }
            
            progressTimer
                .startPublisher(lengthSeconds: halfSecond)
                .sink { completion in
                    
                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                    
                } receiveValue: { (progressValue: Double) in
                                        
                    progress = progressValue
                }
                .store(in: &cancellables)
        }
                        
        #expect(progressTimer.isRunning == false)
        #expect(progress == 1)
    }
    
    @Test("")
    func timerClosureRunsForHalfSecond() async {
        
        let progressTimer = ProgressTimer()
        
        let halfSecond: TimeInterval = 0.5
                
        var progress: Double = 0
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
                continuation.resume(returning: ())
            }
            
            progressTimer.start(lengthSeconds: halfSecond) { (progressValue: Double) in
               
                progress = progressValue
                
            } completed: {
                
                timeoutTask.cancel()
                continuation.resume(returning: ())
            }
        }
                
        #expect(progressTimer.isRunning == false)
        #expect(progress == 1)
    }
}
