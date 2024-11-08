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
    let firebaseAnalytics: FirebaseAnalytics

    // shared analytics tracking
    let trackActionAnalytics: TrackActionAnalytics
            
    init(firebaseAnalytics: FirebaseAnalytics) {
                
        trackActionAnalytics = TrackActionAnalytics(firebaseAnalytics: firebaseAnalytics)

        self.firebaseAnalytics = firebaseAnalytics
    }
}
