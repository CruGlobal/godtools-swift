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
    private let rendererPageModel: MobileContentRendererPageModel
    
    let analyticsEvent: AnalyticsEventModelType
    
    private weak var mobileContentAnalytics: MobileContentAnalytics?
        
    required init(analyticsEvent: AnalyticsEventModelType, mobileContentAnalytics: MobileContentAnalytics, rendererPageModel: MobileContentRendererPageModel) {
        
        self.analyticsEvent = analyticsEvent
        self.mobileContentAnalytics = mobileContentAnalytics
        self.rendererPageModel = rendererPageModel
        
        super.init()
    }
    
    static func initAnalyticsEvents(analyticsEvents: [AnalyticsEventModelType], mobileContentAnalytics: MobileContentAnalytics, rendererPageModel: MobileContentRendererPageModel) -> [MobileContentAnalyticsEvent] {
        
        let events: [MobileContentAnalyticsEvent] = analyticsEvents.map({MobileContentAnalyticsEvent(analyticsEvent: $0, mobileContentAnalytics: mobileContentAnalytics, rendererPageModel: rendererPageModel)})
        
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
        
        mobileContentAnalytics?.trackEvents(events: [analyticsEvent], rendererPageModel: rendererPageModel)
        
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
        if let delayString = analyticsEvent.delay, !delayString.isEmpty {
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
