//
//  MobileContentViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 11/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

protocol MobileContentViewModelType {
    
    var language: LanguageModel { get }
    var analyticsEvents: [MobileContentAnalyticsEvent] { get }
    var defaultAnalyticsEventsTrigger: MobileContentAnalyticsEventTrigger { get }
    
    func mobileContentDidAppear()
    func mobileContentDidDisappear()
}

extension MobileContentViewModelType {
    
    var languageTextAlignment: NSTextAlignment {
        return language.languageDirection == .leftToRight ? .left : .right
    }
    
    func mobileContentDidAppear() {
        
        for event in analyticsEvents {
            let trigger: MobileContentAnalyticsEventTrigger = event.analyticsEvent.getTrigger()
            if trigger == .visible || (trigger == .dependentOnContainingElement && defaultAnalyticsEventsTrigger == .visible) {
                event.trigger()
            }
        }
    }
    
    func mobileContentDidDisappear() {
        
        for event in analyticsEvents {
            let trigger: MobileContentAnalyticsEventTrigger = event.analyticsEvent.getTrigger()
            if trigger == .visible || (trigger == .dependentOnContainingElement && defaultAnalyticsEventsTrigger == .visible) {
                event.cancel()
            }
        }
    }
}
