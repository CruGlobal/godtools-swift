//
//  AnalyticsContainer.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class AnalyticsContainer {
     
    // analytics systems
    let appsFlyerAnalytics: AppsFlyerAnalytics
    let firebaseAnalytics: FirebaseAnalytics

    // shared analytics tracking
    let trackActionAnalytics: TrackActionAnalytics
            
    init(appsFlyerAnalytics: AppsFlyerAnalytics, firebaseAnalytics: FirebaseAnalytics) {
                
        trackActionAnalytics = TrackActionAnalytics(firebaseAnalytics: firebaseAnalytics)

        self.appsFlyerAnalytics = appsFlyerAnalytics
        self.firebaseAnalytics = firebaseAnalytics
    }
}
