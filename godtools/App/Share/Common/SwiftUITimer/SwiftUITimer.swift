//
//  SwiftUITimer.swift
//  SwiftUIViewTimer
//
//  Created by Levi Eggert on 2/13/25.
//

import Foundation
import Combine

class SwiftUITimer: ObservableObject {
    
    private static let defaultRunLoop: RunLoop = .main
    private static let defaultRunLoopMode: RunLoop.Mode = .common
    
    private let intervalSeconds: TimeInterval
    private let repeats: Bool
    
    private var timerPublisher: Timer.TimerPublisher
    private var timerPublisherCancellable: Cancellable?
    private var cancellables: Set<AnyCancellable> = Set()
    private var timerHandledOnce: Bool = false
    
    @Published private(set) var isRunning: Bool = false
    
    init(intervalSeconds: TimeInterval, repeats: Bool = true) {
        
        self.timerPublisher = Self.createNewTimerPublisher(
            intervalSeconds: intervalSeconds
        )
        
        self.intervalSeconds = intervalSeconds
        self.repeats = repeats
    }
    
    deinit {
        invalidate()
    }
    
    static private func createNewTimerPublisher(intervalSeconds: TimeInterval, runLoop: RunLoop? = nil, runLoopMode: RunLoop.Mode? = nil) -> Timer.TimerPublisher {
        
        return Timer.publish(
            every: intervalSeconds,
            on: runLoop ?? Self.defaultRunLoop,
            in: runLoopMode ?? Self.defaultRunLoopMode
        )
    }
    
    private func newTimerPublisher() -> Timer.TimerPublisher {
        
        return Self.createNewTimerPublisher(
            intervalSeconds: intervalSeconds
        )
    }
    
    private func handleInternalTimerInterval() {
        
        timerHandledOnce = true
                
        if timerHandledOnce && repeats == false {
            stop()
        }
    }
    
    var publisher: Timer.TimerPublisher {
        return timerPublisher
    }
    
    func toggle() {
        
        isRunning ? stop() : start()
    }
    
    func start() {
        
        stop()
        
        isRunning = true
        
        timerPublisher = newTimerPublisher()
        
        timerPublisher
        .sink { [weak self] _ in
            self?.handleInternalTimerInterval()
        }
        .store(in: &cancellables)
        
        timerPublisherCancellable = timerPublisher.connect()
    }
    
    func startPublisher() -> AnyPublisher<Date, Never> {
        
        start()
        
        return timerPublisher
            .eraseToAnyPublisher()
    }
    
    func stop() {
        
        guard isRunning else {
            return
        }
        
        isRunning = false
        
        timerPublisherCancellable?.cancel()
        
        timerHandledOnce = false
    }
    
    func invalidate() {
        stop()
    }
}
