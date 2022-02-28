//
//  MobileContentAnalyticsEvent.swift
//  godtools
//
//  Created by Levi Eggert on 11/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentAnalyticsEvent: NSObject {
    
    private var delayTimer: Timer?
    private var triggered: Bool = false
    private let renderedPageContext: MobileContentRenderedPageContext
    
    let analyticsEvent: AnalyticsEvent
    
    private weak var mobileContentAnalytics: MobileContentAnalytics?
        
    required init(analyticsEvent: AnalyticsEvent, mobileContentAnalytics: MobileContentAnalytics, renderedPageContext: MobileContentRenderedPageContext) {
        
        self.analyticsEvent = analyticsEvent
        self.mobileContentAnalytics = mobileContentAnalytics
        self.renderedPageContext = renderedPageContext
        
        super.init()
    }
    
    static func initAnalyticsEvents(analyticsEvents: [AnalyticsEvent], mobileContentAnalytics: MobileContentAnalytics, renderedPageContext: MobileContentRenderedPageContext) -> [MobileContentAnalyticsEvent] {
        
        let events: [MobileContentAnalyticsEvent] = analyticsEvents.map({MobileContentAnalyticsEvent(analyticsEvent: $0, mobileContentAnalytics: mobileContentAnalytics, renderedPageContext: renderedPageContext)})
        
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
        
        mobileContentAnalytics?.trackEvents(events: [analyticsEvent], renderedPageContext: renderedPageContext)
        
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
        
        let delaySeconds: Double = Double(analyticsEvent.delay)
        
        if delaySeconds == 0 {
            
            trackEvent()
        }
        else {
            
            let timer = Timer.scheduledTimer(
                timeInterval: delaySeconds,
                target: self,
                selector: #selector(handleDelayTimer),
                userInfo: nil,
                repeats: false
            )
            
            self.delayTimer = timer
        }
    }
    
    @objc func handleDelayTimer() {
        
        stopDelayTimer()
        
        trackEvent()
    }
}
