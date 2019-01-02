//
//  RecurringTimer.swift
//  godtools
//
//  Created by Igor Ostriz on 11/12/2018.
//  Copyright © 2018 Cru. All rights reserved.
//


class RecurringTimer {
    
    let timeInterval: TimeInterval

    private enum State {
        case suspended
        case resumed
    }

    
    init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }
    
    private var state: State = .suspended
    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource()
    
        t.scheduleRepeating(deadline: .now() + self.timeInterval, interval: self.timeInterval)
// TODO:       Swift 4
//        t.schedule(deadline: .now() + self.timeInterval, repeating: self.timeInterval)
        t.setEventHandler(handler: { [weak self] in
            self?.eventHandler?()
        })
        return t
    }()
    
    var eventHandler: (() -> Void)?
    
    deinit {
        timer.setEventHandler {}
        timer.cancel()
        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
         */
        resume()
        eventHandler = nil
    }
    
    func resume() {
        if state == .resumed {
            return
        }
        state = .resumed
        timer.resume()
    }
    
    func suspend() {
        if state == .suspended {
            return
        }
        state = .suspended
        timer.suspend()
    }
}
