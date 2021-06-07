//
//  MobileContentAnalyticsEvent.swift
//  godtools
//
//  Created by Levi Eggert on 11/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class MobileContentAnalyticsEvent: NSObject {
    
    private var delayTimer: Timer?
    private var triggered: Bool = false
    private var page: MobileContentRendererPageModel
    
    let eventNode: AnalyticsEventNode
    
    private weak var mobileContentAnalytics: MobileContentAnalytics?
    
    required init(eventNode: AnalyticsEventNode, mobileContentAnalytics: MobileContentAnalytics, page: MobileContentRendererPageModel) {
        
        self.eventNode = eventNode
        self.mobileContentAnalytics = mobileContentAnalytics
        self.page = page
        
        super.init()
    }
    
    static func initEvents(eventsNode: AnalyticsEventsNode, mobileContentAnalytics: MobileContentAnalytics, page: MobileContentRendererPageModel) -> [MobileContentAnalyticsEvent] {
        
        let eventNodes: [AnalyticsEventNode] = eventsNode.children as? [AnalyticsEventNode] ?? []
        let events: [MobileContentAnalyticsEvent] = eventNodes.map({MobileContentAnalyticsEvent(eventNode: $0, mobileContentAnalytics: mobileContentAnalytics, page: page)})
        
        return events
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
        
        mobileContentAnalytics?.trackEvent(event: eventNode, page: page)
        
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
