//
//  BlockBasedTimer.swift
//  godtools
//
//  Created by Levi Eggert on 2/19/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class BlockBasedTimer {
    
    private var timer: Timer?
    private var timerClosure: (() -> Void)?
    
    deinit {
        stop()
    }
    
    func start(timeInterval: TimeInterval, repeats: Bool, timerBlock: @escaping (() -> Void)) {
        
        if !isRunning {
            
            timerClosure = timerBlock
            
            timer = Timer.scheduledTimer(
                timeInterval: timeInterval,
                target: self,
                selector: #selector(handleTimerComplete),
                userInfo: nil,
                repeats: repeats
            )
        }
    }
    
    @objc func handleTimerComplete() {
        timerClosure?()
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        timerClosure = nil
    }
    
    var isRunning: Bool {
        return timer != nil
    }
}
