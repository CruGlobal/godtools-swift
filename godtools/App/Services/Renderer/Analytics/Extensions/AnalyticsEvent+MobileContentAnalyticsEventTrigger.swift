//
//  AnalyticsEvent+MobileContentAnalyticsEventTrigger.swift
//  godtools
//
//  Created by Levi Eggert on 2/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

extension AnalyticsEvent {
    
    func getTrigger() -> MobileContentAnalyticsEventTrigger {
        
        switch trigger.name.lowercased() {
        
        case "dependentoncontainingelement":
            return .dependentOnContainingElement
        case "hidden":
            return .hidden
        case "selected":
            return .selected
        case "visible":
            return .visible
            
        default:
            return .dependentOnContainingElement
        }
    }
}
