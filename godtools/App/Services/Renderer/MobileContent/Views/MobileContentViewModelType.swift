//
//  MobileContentViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 11/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol MobileContentViewModelType {
    
    var analyticsEvents: [MobileContentAnalyticsEvent] { get }
    var defaultAnalyticsEventsTrigger: AnalyticsEventNodeTrigger { get }
    
    func mobileContentDidAppear()
    func mobileContentDidDisappear()
}

extension MobileContentViewModelType {
    
    func mobileContentDidAppear() {
        
        for event in analyticsEvents {
            let eventTrigger: AnalyticsEventNodeTrigger = event.eventNode.getTrigger()
            if eventTrigger == .visible || (eventTrigger == .dependentOnContainingElement && defaultAnalyticsEventsTrigger == .visible) {
                event.trigger()
            }
        }
    }
    
    func mobileContentDidDisappear() {
        
        for event in analyticsEvents {
            let eventTrigger: AnalyticsEventNodeTrigger = event.eventNode.getTrigger()
            if eventTrigger == .visible || (eventTrigger == .dependentOnContainingElement && defaultAnalyticsEventsTrigger == .visible) {
                event.cancel()
            }
        }
    }
}
