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
    var heroAnalyticsDictionary: [String: [String: String]] = [:]
    
    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reset),
                                               name: .moveToPageNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reset),
                                               name: .moveToNextPageNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reset),
                                               name: .tractCardStateChangedNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reset),
                                               name: .heroTimedActionNotification,
                                               object: nil)
    }
    
    @objc private func reset() {
        task.cancel()
    }
    
    
    func createDelayedTask(_ delayDouble: Double, with dictionary: [String: String]) {
        if delayDouble > 0 {
            task = DispatchWorkItem { [weak self] in
                self?.sendToAnalyticsIfRelevant(dictionary: dictionary)
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayDouble, execute: task)
        }
    }
    
    func processScreenForHeroEvents(screenName: String) {
        guard heroAnalyticsDictionary.keys.count > 0 else {
            return
        }
        for name in heroAnalyticsDictionary.keys {
            if screenName == name {
                guard let dictionary = heroAnalyticsDictionary[name] else { return }
                let event = TractAnalyticEvent(dictionary: dictionary)
                if event.delay != "" {
                    let delayDouble = Double(event.delay) ?? 0
                    createDelayedTask(delayDouble, with: dictionary)
                }
            }
        }
    }
    
    private func sendToAnalyticsIfRelevant(dictionary: [String: String]) {
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
