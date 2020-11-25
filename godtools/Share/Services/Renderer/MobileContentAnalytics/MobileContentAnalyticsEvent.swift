//
//  MobileContentAnalyticsEvent.swift
//  godtools
//
//  Created by Levi Eggert on 11/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol MobileContentAnalyticsEventDelegate: class {
    
    func mobileContentEventTrackEvent(event: MobileContentAnalyticsEvent, eventNode: AnalyticsEventNode)
}

class MobileContentAnalyticsEvent: NSObject {
    
    private let eventNode: AnalyticsEventNode
    
    private var delayTimer: Timer?
    private var triggered: Bool = false
    
    private weak var delegate: MobileContentAnalyticsEventDelegate?
    
    required init(eventNode: AnalyticsEventNode, delegate: MobileContentAnalyticsEventDelegate) {
        
        self.eventNode = eventNode
        self.delegate = delegate
        
        super.init()
    }
    
    deinit {
        stopDelayTimer()
    }
    
    private func stopDelayTimer() {
        delayTimer?.invalidate()
        delayTimer = nil
    }
    
    private func endTrigger() {
        
        stopDelayTimer()
        
        guard triggered else {
            return
        }
        
        triggered = false
    }
    
    private func trackEvent() {
        
        stopDelayTimer()
        
        delegate?.mobileContentEventTrackEvent(event: self, eventNode: eventNode)
        
        endTrigger()
    }
    
    func cancel() {
        
        stopDelayTimer()
        
        endTrigger()
    }
    
    func trigger() {
        
        guard !triggered else {
            return
        }
        
        triggered = true
        
        let delaySeconds: Double
        if let delayString = eventNode.delay, !delayString.isEmpty {
            delaySeconds = Double(delayString) ?? 0
        }
        else {
            delaySeconds = 0
        }
        
        guard delaySeconds == 0 else {
            
            let timer = Timer.scheduledTimer(
                timeInterval: delaySeconds,
                target: self,
                selector: #selector(handleDelayTimer),
                userInfo: nil,
                repeats: false
            )
            
            self.delayTimer = timer
            
            return
        }
                
        trackEvent()
    }
    
    @objc func handleDelayTimer() {
        
        stopDelayTimer()
        
        trackEvent()
    }
}
