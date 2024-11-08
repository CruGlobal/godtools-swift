//
//  ToolOpenedAnalytics.swift
//  godtools
//
//  Created by Levi Eggert on 3/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ToolOpenedAnalytics {
    
    private let keyFirstToolOpened: String = "toolOpenedAnalytics.keyFirstToolOpened"
    
    init() {

    }
    
    func trackToolOpened(resource: ResourceModel) {
        // TODO: Should we send to Firebase? Commented in https://jira.cru.org/browse/GT-1535. ~Levi
        //appsFlyerAnalytics.trackAction(actionName: "tool-opened", data: nil)
    }
    
    func trackFirstToolOpenedIfNeeded(resource: ResourceModel) {
        
        if !firstToolOpened {

            // TODO: Should we send to Firebase? Commented in https://jira.cru.org/browse/GT-1535. ~Levi
            //appsFlyerAnalytics.trackAction(actionName: "first-tool-opened", data: nil)
                        
            defaults.set(true, forKey: keyFirstToolOpened)
            defaults.synchronize()
        }
    }
    
    private var defaults: UserDefaults {
        return UserDefaults.standard
    }
    
    private var firstToolOpened: Bool {
        return (defaults.object(forKey: keyFirstToolOpened) as? Bool) ?? false
    }
}
