//
//  MultiplatformAnalyticsEvent.swift
//  godtools
//
//  Created by Levi Eggert on 8/12/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformAnalyticsEvent: AnalyticsEventModelType {
    
    private let analyticsEvent: AnalyticsEvent
    
    required init(analyticsEvent: AnalyticsEvent) {
        
        self.analyticsEvent = analyticsEvent
    }
    
    var attribute: AnalyticsAttributeModel? {
        return nil // TODO: Set this. ~Levi
    }
    
    var action: String? {
        return analyticsEvent.action
    }
    
    var delay: String? {
        return String(analyticsEvent.delay)
    }
    
    var systems: [String] {
        return Array() // TODO: Set this. ~Levi
    }
    
    var trigger: MobileContentAnalyticsEventTrigger {
        return .visible// TODO: Set this. ~Levi
    }
}
