//
//  PageViewedAnalytics.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class PageViewedAnalytics {
    
    private let firebaseAnalytics: FirebaseAnalytics
    private let snowplowAnalytics: SnowplowAnalytics
    
    required init(firebaseAnalytics: FirebaseAnalytics, snowplowAnalytics: SnowplowAnalytics) {
        
        self.firebaseAnalytics = firebaseAnalytics
        self.snowplowAnalytics = snowplowAnalytics
    }
    
    func trackPageView(trackScreen: TrackScreenModel) {
                
        firebaseAnalytics.trackScreenView(
            screenName: trackScreen.screenName,
            siteSection: trackScreen.siteSection,
            siteSubSection: trackScreen.siteSubSection,
            contentLanguage: trackScreen.contentLanguage,
            secondaryContentLanguage: trackScreen.secondaryContentLanguage
        )
        
        snowplowAnalytics.trackScreenView(screenName: trackScreen.screenName)
    }
}
