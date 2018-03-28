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
    
    var tractName: String = ""
    var tractCardName: String = ""
    var tractButtonName: String = ""
    var tractPlusCardName: String = ""
    var tractCardCurrentNames: [String] = []
    var tractCardNextNames: [String] = []
    var tractCardNumbers: [Int] = []
    var currentTractCardCount = 0
    var currentCard: String = ""
    var viewListener: String = ""
    var timer = Timer()
    var timerCounter = 5
    var isTimerRunning = false
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        isTimerRunning = true
    }
    
    @objc func updateTimer() {
        if timerCounter < 1 && isTimerRunning {
            timer.invalidate()
            timerCounter = 0
            isTimerRunning = false
            let tractCardName = tractPlusCardName
            sendToAnalyticsIfRelevant(tractCardName: tractCardName)
        } else if isTimerRunning {
            timerCounter = self.timerCounter - 1
            isTimerRunning = true
        } else {
            timer.invalidate()
            isTimerRunning = false
            timerCounter = 0
        }
    }
    
    func sendToAnalyticsIfRelevant(tractCardName: String) {
        if !isTimerRunning {
            print("You Read this card for more than 7s >> \(tractCardName)")
            timer.invalidate()
            isTimerRunning = false
            timerCounter = 0
        }
    }

}
