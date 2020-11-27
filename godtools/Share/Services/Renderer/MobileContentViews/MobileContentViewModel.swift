//
//  MobileContentViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol MobileContentViewModel {
    
    var analyticsEvents: [MobileContentAnalyticsEvent] { get }
    var defaultAnalyticsEventsTrigger: AnalyticsEventNodeTrigger { get }
    
    func mobileContentViewDidAppear()
    func mobileContentViewDidDisappear()
}

extension MobileContentViewModel {
    
    
    func mobileContentViewDidAppear() {
        
        for event in analyticsEvents {
            let eventTrigger: AnalyticsEventNodeTrigger = event.eventNode.getTrigger()
            if eventTrigger == .visible || (eventTrigger == .dependentOnContainingElement && defaultAnalyticsEventsTrigger == .visible) {
                event.trigger()
            }
        }
    }
    
    func mobileContentViewDidDisappear() {
        
        for event in analyticsEvents {
            let eventTrigger: AnalyticsEventNodeTrigger = event.eventNode.getTrigger()
            if eventTrigger == .visible || (eventTrigger == .dependentOnContainingElement && defaultAnalyticsEventsTrigger == .visible) {
                event.cancel()
            }
        }
    }
}
