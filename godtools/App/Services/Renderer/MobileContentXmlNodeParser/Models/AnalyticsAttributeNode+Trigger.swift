//
//  AnalyticsAttributeNode+Trigger.swift
//  godtools
//
//  Created by Levi Eggert on 11/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

extension AnalyticsEventNode {
    
    func getTrigger() -> AnalyticsEventNodeTrigger {
        
        guard let triggerValue = trigger?.lowercased() else {
            return .dependentOnContainingElement
        }
        
        guard let trigger =  AnalyticsEventNodeTrigger(rawValue: triggerValue) else {
            return .dependentOnContainingElement
        }
        
        return trigger
    }
}
