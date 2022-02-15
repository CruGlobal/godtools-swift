//
//  AnalyticsEventModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol AnalyticsEventModelType {
        
    var action: String? { get }
    var delay: String? { get }
    var systems: [String] { get }
    var triggerName: String? { get }
    
    func getAttributes() -> [String: String]
    func getTrigger() -> MobileContentAnalyticsEventTrigger
}

extension AnalyticsEventModelType {
    
    func getTrigger() -> MobileContentAnalyticsEventTrigger {
        
        let defaultTrigger: MobileContentAnalyticsEventTrigger = .dependentOnContainingElement
        
        guard let triggerName = self.triggerName else {
            return defaultTrigger
        }
        
        return MobileContentAnalyticsEventTrigger(rawValue: triggerName) ?? defaultTrigger
    }
}
