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
    
    init(firebaseAnalytics: FirebaseAnalytics) {
        
        self.firebaseAnalytics = firebaseAnalytics
    }
    
    func trackAction(trackAction: TrackActionModel) {
                
        firebaseAnalytics.trackAction(
            screenName: trackAction.screenName,
            siteSection: trackAction.siteSection,
            siteSubSection: trackAction.siteSubSection,
            contentLanguage: trackAction.contentLanguage,
            secondaryContentLanguage: trackAction.secondaryContentLanguage,
            actionName: trackAction.actionName,
            data: trackAction.data
        )
    }
}
