//
//  ProgressTimer.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ProgressTimer {
    
    private static let intervalRatePerSecond: TimeInterval = 60
    private static let interval: TimeInterval = 1 / ProgressTimer.intervalRatePerSecond
    
    private var progressTimer: Timer?
    private var maxIntervalCount: Double = 0
    private var intervalCount: Double = 0
    private var progress: Double = 0 {
        didSet {
            progressChangedClosure?(progress)
        }
    }
    private var progressChangedClosure: ((_ progress: Double) -> Void)?
    private var progressCompletedClosure: (() -> Void)?
    
    init() {
        
    }
    
    deinit {
        stop()
    }
    
    private static func getIntervalCountForSeconds(seconds: Double) -> Double {
        
        let wholeSeconds: Double = floor(seconds)
        let remainingSeconds: Double = seconds - wholeSeconds
        let roundedRemainingSeconds: Double = ProgressTimer.roundToNearestHundredth(number: remainingSeconds)
        
        let intervalCountForWholeSeconds: Double = ProgressTimer.intervalRatePerSecond * wholeSeconds
        let intervalCountForRemainingSeconds: Double = floor(ProgressTimer.intervalRatePerSecond * roundedRemainingSeconds)
        
        let intervalCount: Double = intervalCountForWholeSeconds + intervalCountForRemainingSeconds
        
        return intervalCount
    }
    
    private static func roundToNearestHundredth(number: Double) -> Double {
                
        let roundingBehavior = NSDecimalNumberHandler(
            roundingMode: .plain,
            scale: 2,
            raiseOnExactness: false,
            raiseOnOverflow: false,
            raiseOnUnderflow: false,
            raiseOnDivideByZero: false
        )
        
        let roundedDecimalNumber = NSDecimalNumber(value: number).rounding(accordingToBehavior: roundingBehavior)
        
        return roundedDecimalNumber.doubleValue
    }
    
    var isRunning: Bool {
        return progressTimer != nil
    }
    
    func changeRemainingSeconds(seconds: Double) {
        
        guard isRunning else {
            return
        }
        
        let intervalCountForSeconds: Double = ProgressTimer.getIntervalCountForSeconds(seconds: seconds)
        let newMaxIntervalCount: Double = intervalCountForSeconds
        
        self.maxIntervalCount = newMaxIntervalCount
        self.intervalCount = progress * newMaxIntervalCount
    }
    
    func start(lengthSeconds: TimeInterval, changed: @escaping ((_ progress: Double) -> Void), completed: @escaping (() -> Void)) {
        
        guard !isRunning else {
            return
        }
        
        self.maxIntervalCount = ProgressTimer.getIntervalCountForSeconds(seconds: lengthSeconds)
        
        progressChangedClosure = changed
        progressCompletedClosure = completed
        
        progressTimer = Timer.scheduledTimer(
            timeInterval: ProgressTimer.interval,
            target: self,
            selector: #selector(handleProgressTimerInterval),
            userInfo: nil,
            repeats: true
        )
    }
    
    func stop() {
        
        guard let progressTimer = self.progressTimer else {
            return
        }
        
        progressChangedClosure = nil
        
        progressTimer.invalidate()
        self.progressTimer = nil
        
        intervalCount = 0
    }
    
    @objc private func handleProgressTimerInterval() {

        intervalCount += 1
        
        let completed: Bool = intervalCount >= maxIntervalCount
        
        guard !completed else {
            
            intervalCount = maxIntervalCount
            progress = 1
            
            progressCompletedClosure?()
                                    
            return
        }
                
        progress = intervalCount / maxIntervalCount
    }
}
