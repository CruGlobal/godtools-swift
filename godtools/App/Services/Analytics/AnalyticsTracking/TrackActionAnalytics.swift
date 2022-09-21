//
//  TrackActionAnalytics.swift
//  godtools
//
//  Created by Robert Eldredge on 5/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class TrackActionAnalytics {
    
    private let firebaseAnalytics: FirebaseAnalytics
    private let snowplowAnalytics: SnowplowAnalytics
    
    required init(firebaseAnalytics: FirebaseAnalytics, snowplowAnalytics: SnowplowAnalytics) {
        
        self.firebaseAnalytics = firebaseAnalytics
        self.snowplowAnalytics = snowplowAnalytics
    }
    
    func trackAction(trackAction: TrackActionModel) {
                
        firebaseAnalytics.trackAction(
            screenName: trackAction.screenName,
            siteSection: trackAction.siteSection,
            siteSubSection: trackAction.siteSubSection,
            actionName: trackAction.actionName,
            data: trackAction.data
        )
        
        snowplowAnalytics.trackAction(actionName: trackAction.actionName)
    }
}
