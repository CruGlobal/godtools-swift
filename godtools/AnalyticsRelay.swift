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
    
    func runTimer(dictionary: [String: String]) {
       // timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
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

            let tractCardName = screenNamePlusCardLetterName
        } else if isTimerRunning {
            timerCounter = self.timerCounter - 1
            isTimerRunning = true
        } else {
            timer.invalidate()
            isTimerRunning = false
            timerCounter = 0
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

            
            //var userInfo /*[String: Any]*/ = dictionary
            /*
            switch tractCardName {
            case "kgp-us-5a":
                userInfo[AdobeAnalyticsConstants.Keys.gospelPresentedTimedAction]  = 1
                userInfo["action"] = AdobeAnalyticsConstants.Values.kgpUSGospelPresented
            case "satisfied-6a":
                userInfo[AdobeAnalyticsConstants.Keys.presentingHolySpiritTimedAction]  = 1
                userInfo["action"] = AdobeAnalyticsConstants.Values.satisfiedHolySpiritPresented
            case "honorrestored-4d":
                userInfo[AdobeAnalyticsConstants.Keys.gospelPresentedTimedAction]  = 1
                userInfo["action"] = AdobeAnalyticsConstants.Values.honorRestoredPresented
            case "thefour-5":
                userInfo[AdobeAnalyticsConstants.Keys.gospelPresentedTimedAction]  = 1
                userInfo["action"] = AdobeAnalyticsConstants.Values.theFourGospelPresented
            case "kgp-5a":
                userInfo[AdobeAnalyticsConstants.Keys.gospelPresentedTimedAction]  = 1
                userInfo["action"] = AdobeAnalyticsConstants.Values.kgpGospelPresented
            case "fourlaws-6a":
                userInfo[AdobeAnalyticsConstants.Keys.gospelPresentedTimedAction]  = 1
                userInfo["action"] = AdobeAnalyticsConstants.Values.fourLawsGospelPresented
            default :
                break
            }
            */

        }
    }

}
