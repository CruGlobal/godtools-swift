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
    
    func mobileContentDidAppear()
    func mobileContentDidDisappear()
}

extension MobileContentViewModelType {
    
    var languageTextAlignment: NSTextAlignment {
        return language.languageDirection == .leftToRight ? .left : .right
    }
    
    func mobileContentDidAppear() {
        
        for event in analyticsEvents {
            
            let trigger: AnalyticsEvent.Trigger = event.analyticsEvent.trigger

            if trigger == .visible {
                event.trigger()
            }
        }
    }
    
    func mobileContentDidDisappear() {
        
        for event in analyticsEvents {
            
            let trigger: AnalyticsEvent.Trigger = event.analyticsEvent.trigger
            
            if trigger == .visible {
                event.cancel()
            }
        }
    }
}
