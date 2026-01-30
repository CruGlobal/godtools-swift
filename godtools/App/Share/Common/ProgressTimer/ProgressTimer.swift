//
//  ProgressTimer.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class ProgressTimer {
    
    private static let intervalRatePerSecond: TimeInterval = 60
    private static let interval: TimeInterval = 1 / ProgressTimer.intervalRatePerSecond
    
    private let currentProgressSubject: CurrentValueSubject<Double, Never> = CurrentValueSubject(0)
    private let loggingEnabled: Bool
    
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
    
    private(set) var isPaused: Bool = false
    
    init(loggingEnabled: Bool = false) {
        
        self.loggingEnabled = loggingEnabled
        
        log(message: "init")
    }
    
    deinit {
        
        log(message: "deinit")
        
        stop()
    }
    
    private func log(message: String) {
       
        guard loggingEnabled else {
            return
        }
        
        print("\n Progress Timer")
        print("  message: \(message)")
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
            log(message: "already running...")
            return
        }
        
        isPaused = false
        
        self.maxIntervalCount = ProgressTimer.getIntervalCountForSeconds(seconds: lengthSeconds)
        
        progressChangedClosure = changed
        progressCompletedClosure = completed
        
        log(message: "start")
        
        progressTimer = Timer.scheduledTimer(
            timeInterval: ProgressTimer.interval,
            target: self,
            selector: #selector(handleProgressTimerInterval),
            userInfo: nil,
            repeats: true
        )
    }
    
    func startPublisher(lengthSeconds: TimeInterval) -> AnyPublisher<Double, Never> {
        
        start(lengthSeconds: lengthSeconds) { [weak self] (progress: Double) in
            self?.currentProgressSubject.send(progress)
        } completed: { [weak self] in
            self?.currentProgressSubject.send(completion: .finished)
        }
        
        return currentProgressSubject
            .eraseToAnyPublisher()
    }
    
    func pause(progress: Double?) {
        
        log(message: "pause")
        
        isPaused = true
        
        guard let progress = progress else {
            return
        }
        
        intervalCount = progress * maxIntervalCount
        self.progress = progress
    }
    
    func resume() {
        
        isPaused = false
    }
    
    func stop() {
        
        guard let progressTimer = self.progressTimer else {
            return
        }
        
        log(message: "stop")
        
        progressChangedClosure = nil
        progressCompletedClosure = nil
        
        progressTimer.invalidate()
        self.progressTimer = nil
        
        isPaused = false
        
        intervalCount = 0
    }
    
    @objc private func handleProgressTimerInterval() {

        guard !isPaused else {
            log(message: "is paused...")
            return
        }
        
        intervalCount += 1
        
        let completed: Bool = intervalCount >= maxIntervalCount
        
        guard !completed else {
            
            intervalCount = maxIntervalCount
            progress = 1
            
            progressCompletedClosure?()
                        
            stop()
            
            log(message: "handleProgressTimerInterval\n completed: \(progress)")
            
            return
        }
                
        progress = intervalCount / maxIntervalCount
        
        log(message: "handleProgressTimerInterval\n progress: \(progress)")
    }
}
