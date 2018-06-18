//
//  AnalyticsRelay.swift
//  godtools
//
//  Created by Greg Weiss on 3/26/18.
//  Copyright © 2018 Cru. All rights reserved.
//

import Foundation

class AnalyticsRelay {
    
    static let shared = AnalyticsRelay()
    
    var screenName: String = ""
    var screenNamePlusCardLetterName: String = ""
    
    // These arrays keep track of what current cards are in a viewable stack.
    // This is used for preventing a false report being sent to analytics tracking.
    var tractCardCurrentLetterNames: [String] = []
    var tractCardNextLetterNames: [String] = []
    
    var viewListener: String = ""
    var timer = Timer()
    var timerCounter = 0
    var isTimerRunning = false
    var task = DispatchWorkItem { }
    
    
    func runTimer(dictionary: [String: String]) {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: dictionary, repeats: true)
        isTimerRunning = true
    }
    
    @objc func updateTimer() {
        if timerCounter < 1 && isTimerRunning {
            timerCounter = 0
            isTimerRunning = false
            if let analyticsData = timer.userInfo as? [String: String] {
                sendToAnalyticsIfRelevant(dictionary: analyticsData)
            }
            timer.invalidate()

        } else if isTimerRunning {
            timerCounter = self.timerCounter - 1
            isTimerRunning = true
        } else {
            timer.invalidate()
            isTimerRunning = false
            timerCounter = 0
        }
    }
    
    func createDelayedTask(_ delayDouble: Double, with dictionary: [String: String]) {
        if delayDouble > 0 {
            task = DispatchWorkItem {
                self.sendToAnalyticsIfRelevant(dictionary: dictionary)
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayDouble, execute: task)
        } else {
            task.cancel()
        }
    }
    
    func sendToAnalyticsIfRelevant(dictionary: [String: String]) {
        if !isTimerRunning {
            timer.invalidate()
            isTimerRunning = false
            timerCounter = 0
            
            NotificationCenter.default.post(name: .actionTrackNotification,
                                            object: nil,
                                            userInfo: dictionary)
        }
    }

}
